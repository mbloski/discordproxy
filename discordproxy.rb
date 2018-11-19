# coding: UTF-8

require 'socket'
require 'openssl'

require './output'
require './eval'

require './api'

require 'json'
require 'erlang/etf'
require 'zlib'

$inflater = Zlib::Inflate.new
$deflater = Zlib::Deflate.new

class DiscordProxy
  def initialize(bindport, host, port, format = :json)
    cert = 'fauxdiscord-cert.pem'
    key = 'fauxdiscord-key.pem'

    @format = format

    @api = nil

    @recvbuf = String.new
    @toread = -1

    @socket = TCPSocket.open(host,port)
    ssl_context = OpenSSL::SSL::SSLContext.new()
    @socket = OpenSSL::SSL::SSLSocket.new(@socket, ssl_context)

    @psocket = TCPServer.new("0.0.0.0", bindport)
    Output.Info "PROXY", "listening on 0.0.0.0:#{bindport}"
    ssl_context = OpenSSL::SSL::SSLContext.new
    Output.Info "PROXY", "using #{cert}"
    ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(cert))
    ssl_context.key = OpenSSL::PKey::RSA.new(File.open(key))
    @psocket = OpenSSL::SSL::SSLServer.new(@psocket, ssl_context)    

    @pclient = @psocket.accept
    @socket.connect
    Output.Info "PROXY", "connected to #{host}:#{port}"
    @start_time = Time.now
  end

  def process_from_discord(str)
    if @format == :etf
       data = Erlang.binary_to_term(str)
    elsif @format == :json
      data = JSON.parse(str)
    else
      raise 'unsupported data format'
    end

    Output.Info "D! <<<", (data['t']) || '???'

    if data['t'] == 'MESSAGE_DELETE'
      data['t'] = 'MESSAGE_REACTION_ADD'
      data['d']['message_id'] = data['d']['id']
      #data['d']['user_id'] = '257931869138452481'
      data['d']['emoji'] = {'name' => "\xF0\x9F\x97\x91", 'id' => nil, 'animated' => false}
      return data
    end

    if data['t'] == 'MESSAGE_CREATE'
      # data['d']['author']['username'] / id / discriminator
      message = data['d']
      if message['content'].start_with?('!')
        token = (message['content'][1..-1]).split(' ')
        if token[0] == 'ping'
          @api.send_message(message['channel_id'], 'pong')
        end

        if message['author']['username'] == 'blo' and message['author']['discriminator'] == '0795'
          if token[0] == 'eval' or token[0] == 'meval'
            cnt = message['content'][((token[0]).length + 1)..-1]
            ret = Eval.do_eval(cnt)
            if token[0] == 'meval'
              ret = '```' + ret + '```'
            end

            @api.edit_message(message['channel_id'], message['id'], ret)
          end
        end
      end
    end
    data
  end

  def process_to_discord(str)
   if @format == :etf
     data = Erlang.binary_to_term(str)
   elsif @format == :json
     data = JSON.parse(str)
   else
     raise 'unsupported data format'
   end

   op = data['op']
   if op == 2 or op == 6
     @api = API.new(data['d']['token'])
   end
   Output.Info "D! >>>", data.inspect
   return true
  end

  def send(packet, _dest = @socket)
    dest.each{|d| d.write(packet)}
  end

  def recv_from_discord
    r = IO.select([@socket], nil, nil, 0.01)
    if r
      if @toread > 0
        r = @socket.read(@toread)
        if r.nil?
          return false
        end
        @toread -= r.length
        @recvbuf += r
      else
        indic = @socket.read(1)
        if indic.nil?
          return false
        end
        if indic.ord == 0x82
          len = @socket.read(1)
          rlen = len.ord
          if len.ord == 126
            len = @socket.read(2)
            rlen = len.unpack('S>').first
          elsif len.ord == 127
            len = @socket.read(8)
            rlen = len.unpack('Q>').first
          end
          @toread = rlen
          rpayload = @socket.read(rlen)
          @recvbuf += rpayload
          @toread = rlen - rpayload.length

          data = len + rpayload
        else
          data = @socket.read_nonblock(2047)
          @pclient.write(indic + data)
          return nil
        end
      end

      if @toread == 0
        recvdata = $inflater.inflate(@recvbuf)
        pass = process_from_discord(recvdata)
        if not pass.nil?
          payload = (@format == :etf)? Erlang.term_to_binary(pass) : pass.to_json
          payload = $deflater.deflate(payload, Zlib::SYNC_FLUSH)
          nlen = payload.length
          if nlen > 65535
            plen = 127.chr + [nlen].pack('Q>')
          elsif nlen > 125
            plen = 126.chr + [nlen].pack('S>')
          else
            plen = nlen.chr
          end

          sent = @pclient.write(indic + plen + payload)
        else
          Output.Debug "BLOCK", "Buffer discarded: #{recvdata}"
        end

        @recvbuf = ''
      end

      return data
    end
    nil
  end

  def send_to_discord
    r = IO.select([@pclient], nil, nil, 0.01)
    if r
      indic = @pclient.read(1)
      if indic.nil?
        return false
      end
      f = (indic.ord & 0xF0) >> 4
      opcode = indic.ord & 0x0F
      if f == 8 and opcode.ord == 1 or opcode.ord == 2
        len = @pclient.read(1)
        rlen = len.ord & 127
        if rlen == 126
          len += @pclient.read(2)
          rlen = len.unpack('S>').first
        elsif rlen == 127
          len += @pclient.read(8)
          rlen = len.unpack('Q>').first
        end
        mask = @pclient.read(4)
        rpayload = @pclient.read_nonblock(rlen)

        payload = rpayload.bytes.each_with_index.map{|x,i| (x ^ (mask[i % 4]).ord).chr}.join

        pass = process_to_discord(payload)
        if pass
          @socket.write(indic + len + mask + rpayload)
        end
      else
        data = @pclient.read_nonblock(2047)
        @socket.write(data)
      end

      return data
    end
    nil
  end

  def tick
    if send_to_discord() === false
      raise 'connection closed by client'
    end
    if recv_from_discord() === false
      raise 'connection closed by server'
    end
  end
end
