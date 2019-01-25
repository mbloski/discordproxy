# discordproxy
discordproxy is a simple proxy server made specifically for Discord (http://discordapp.com)

## Requirements
1. Ruby compiled with OpenSSL

## Dependencies
1. `erlang/etf` for ETF support
2. `google/cloud/translate` for automatic I/O translation

## Installation
1. unpack core.asar: `asar extract core.asar core/`
2. patch the discord client using `discord_desktop_core_certificate.patch`
3. re-pack core.asar: `asar pack core/ core.asar`
4. add the following entry to your HOSTS file: `127.0.0.1 gateway.discord.gg`
- Note: it's not necessary to patch the client. You can run discord with `--ignore-certificate-errors` instead: `./Discord --args --ignore-certificate-errors`
---
- Alternatively, when running Discord in a web browser
1. import the bundled certificate into your web browser
2. ensure the web browser ignores certificate errors, i.e. Chromium must be run with `--ignore-certificate-errors`
3. update the HOSTS file
4. navigate to discordapp.com as usual  
- Note: the browser client uses JSON data format in communication with server. The proxy must be initialized with JSON mode: `DiscordProxy.new 443, "104.16.60.37", 443, :json`

## Features
1. `!ding` - responds with uptime notice
2. `!eval [code]` - evaluates Ruby code and prints output in current channel
3. `!beval [code]` - same as `!eval`, but wraps the output in a markdown block
4. deleted messages get a trash bin reaction instead of being purged
5. `!toggle_translate_input [lang_code]` - toggles automatic translation of outgoing messages in current channel
6. `!toggle_translate_output [lang_code]` - toggles automatic translation of incoming messages in current channel

## Disclaimer
Technically, running discordproxy is against Discord Terms of Service (https://discordapp.com/terms). I take zero responsibility if this gets your account banned.

---
This software is licensed under the terms of the MIT license.
