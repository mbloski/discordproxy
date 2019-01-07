require "google/cloud/translate"

ENV["TRANSLATE_PROJECT"]     = "My First Project"
ENV["TRANSLATE_CREDENTIALS"] = "translate.json"

translate = Google::Cloud::Translate.new

translation = translate.translate "Hello world!", to: "la"

p translation.to_s

puts translation #=> Salve mundi!
