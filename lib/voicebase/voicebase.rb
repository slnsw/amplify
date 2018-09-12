module Voicebase
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key, :voicebase_api_url

    def initialize
      @api_key = ''
      @voicebase_api_url = "https://apis.voicebase.com/v3/"
    end
  end

  class Client
    include HTTParty

    attr_accessor :voicebase_api_key, :voicebase_url

    def initialize
      @voicebase_api_key = Voicebase.configuration.api_key
      @voicebase_url = Voicebase.configuration.url
    end

    def upload_media()
      medial_url = "https://slnsw-amplify.s3.amazonaws.com/collections_v2/snowymountain_bushfires/audio/mloh307-0001-0004-s002-m.mp3"
      @result = HTTParty.post(
        "#{@voicebase_url}media",
        :body => { :mediaUrl => medial_url,
      }.to_json,
      :headers => {
        'Authorization' => @voicebase_api_key.to_s,
        'Content-Type' => 'multipart/form-data'
      } )
      require 'pry'; binding.pry
    end
  end
end
