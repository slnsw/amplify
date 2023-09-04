Rails.application.reloader.to_prepare do
  Voicebase.configure do |config|
    config.api_key = ENV["VOICEBASE_API_KEY"]
  end
end
