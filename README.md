# discordproxy
discordproxy is a simple proxy server made specifically for Discord (http://discordapp.com)

## Requirements
1. Ruby compiled with OpenSSL

## Dependencies
1. `erlang/etf` for ETF support
2. `google/cloud/translate` for automatic I/O translation

## Features
1. `!ding` - responds with uptime notice
2. deleted messages get a trash bin reaction instead of being purged
3. `!toggle_translate_input [lang_code]` - toggles automatic translation of outgoing messages in current channel
4. `!toggle_translate_output [lang_code]` - toggles automatic translation of incoming messages in current channel

This software is licensed under the terms of the MIT license.
