require 'uri'
require 'net/http'
require 'net/https'

class API
  def initialize(_token)
    @token = _token
  end

  def send_message(channel, str)
    uri = URI.parse("https://discordapp.com/api/v6/channels/#{channel}/messages")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    header = {'content-type': 'text/json', 'authorization': @token}
    request = Net::HTTP::Post.new(uri.request_uri, header)
    body = {'content': str, 'tts': false}
    request.body = body.to_json
    return http.request(request)
  end

  def edit_message(channel, message, str)
    uri = URI.parse("https://discordapp.com/api/v6/channels/#{channel}/messages/#{message}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Patch.new(uri.request_uri)
    request.add_field('content-type', 'application/json')
    request.add_field('authorization', @token)
    body = {'content': str}
    request.body = body.to_json
    return http.request(request)
  end
end
