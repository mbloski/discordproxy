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
3. pack core.asar: `asar pack core/ core.asar`
4. add the following entry to your HOSTS file: `127.0.0.1 gateway.discord.gg`
---
- Alternatively, when running Discord in a web browser
1. import the bundled certificate into your web browser
2. ensure the web browser ignores certificate errors, i.e. Chromium needs to be run with `--ignore-certificate-errors`
3. update the HOSTS file
4. navigate to discordapp.com as usual

## Features
1. `!ding` - responds with uptime notice
2. deleted messages get a trash bin reaction instead of being purged
3. `!toggle_translate_input [lang_code]` - toggles automatic translation of outgoing messages in current channel
4. `!toggle_translate_output [lang_code]` - toggles automatic translation of incoming messages in current channel

This software is licensed under the terms of the MIT license.
