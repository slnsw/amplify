require 'formdata'
require 'stringio'
require 'net/http'

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
    attr_accessor :voicebase_api_key, :voicebase_url

    def initialize
      @voicebase_api_key = ENV["VOICEBASE_API_KEY"]  #Voicebase.configuration.api_key
      @voicebase_url = "https://apis.voicebase.com/v3/"  # Voicebase.configuration.voicebase_api_url
    end

    def get_transcript(media_id, format: 'srt')
      get_request("https://apis.voicebase.com/v3/media/#{media_id}/transcript/#{format}")
    end

    def check_progress(media_id)
      get_request("https://apis.voicebase.com/v3/media/#{media_id}/progress")
    end


    def upload_media(media_url)
      # create form data
      f = FormData.new
      f.append('configuration', '')
      f.append('mediaUrl', media_url)

      uri = URI.parse("https://apis.voicebase.com/v3/media")

      req = Net::HTTP::Post.new(uri)
      req.content_type = f.content_type
      req.content_length = f.size
      req.body_stream = f
      req.add_field("Authorization", "Bearer #{@voicebase_api_key}")

      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true
      http.request(req)
    end

    private

    def get_request(url)
      uri = URI.parse(url)

      req = Net::HTTP::Get.new(uri)
      req.add_field("Authorization", "Bearer #{@voicebase_api_key}")

      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true
      http.request(req)
    end
  end
end
