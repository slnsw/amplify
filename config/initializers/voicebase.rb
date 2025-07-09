require 'voicebase/voicebase'

Voicebase.configure do |config|
  config.api_key = ENV["VOICEBASE_API_KEY"]
end
