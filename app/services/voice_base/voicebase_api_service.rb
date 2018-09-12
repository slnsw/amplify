module VoiceBase
  class VoicebaseApiService
    attr_accessor :transcript

    def initialize(transcript_id)
      @transcript = Transcript.find(transcript_id)
    end

    def upload_media
      # res = Voicebase::Client.new.upload_media(@transcript.audio_url)
      res = Voicebase::Client.new.upload_media("https://slnsw-amplify.s3.amazonaws.com/collections_v2/snowymountain_bushfires/audio/mloh307-0001-0004-s002-m.mp3")
      status = JSON.parse res.body
      if status["errors"]
        #TODO: upload to bugsnag
      else
        @transcript.update_column("voicebase_media_id", status["mediaId"])
      end
    end

    def check_progress
      @transcript.reload
      res = Voicebase::Client.new.check_progress(@transcript.voicebase_media_id)
      status = JSON.parse res.body
      if status["errors"]
        #TODO: upload to bugsnag
      else
        @transcript.update_column("voicebase_status", status["progress"]["status"])
      end
    end

    def get_transcript
      @transcript.reload
      res = Voicebase::Client.new.get_transcript(@transcript.voicebase_media_id)
      require 'pry'; binding.pry
      status = JSON.parse res.body

      if res.code == "200"
        p status
      else
        #TODO: upload to bugsnag
      end
    end
  end
end

