require './discordproxy.rb'

Output.Info "PROXY", "terrible discord proxy at ur service"

proxy = DiscordProxy.new 443, "104.16.60.37", 443, :json

loop do
  begin
    proxy.tick
  rescue StandardError => e
    Output.Error "PROXY", e.message
    exit 0
  end
end
