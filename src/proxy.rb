require './discordproxy.rb'

# Environment for Google Translate API
ENV["TRANSLATE_PROJECT"]     = "My First Project"
ENV["TRANSLATE_CREDENTIALS"] = "../translate.json"

Output.Info "PROXY", "discordproxy at your service"

proxy = DiscordProxy.new 443, "104.16.60.37", 443, :etf

loop do
  begin
    proxy.tick
  rescue StandardError => e
    Output.Error "PROXY", e.message
    exit 0
  end
end
