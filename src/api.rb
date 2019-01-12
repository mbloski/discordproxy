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
    header = {'content-type': 'application/json', 'authorization': @token}
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

  def add_reaction(channel, message, emoji)
    uri = URI.parse("https://discordapp.com/api/v6/channels/#{channel}/messages/#{message}/reactions/#{emoji}/@me")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Put.new(uri.request_uri)
    request.add_field('content-type', 'application/json')
    request.add_field('authorization', @token)
    return http.request(request)
  end

  def get_user(id)
    uri = URI.parse("https://discordapp.com/api/v6/users/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field('authorization', @token)
    response = http.request(request)
    return JSON.parse(response.body)
  end
end
