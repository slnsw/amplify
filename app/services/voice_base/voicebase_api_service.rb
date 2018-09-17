module VoiceBase
  class VoicebaseApiService
    attr_accessor :transcript

    def self.upload_media(transcript_id)
      transcript = Transcript.find(transcript_id)

      #FIXME
      if Rails.env.development?
        res = Voicebase::Client.new.upload_media("https://slnsw-amplify.s3.amazonaws.com/collections_v2/snowymountain_bushfires/audio/mloh307-0001-0004-s002-m.mp3")
      else
        res = Voicebase::Client.new.upload_media(transcript.audio_url)
      end
      status = JSON.parse res.body
      if status["errors"]
        #TODO: upload to bugsnag
      else
        transcript.update_column("voicebase_media_id", status["mediaId"])
      end
    end

    def self.check_progress(transcript_id)
      transcript = Transcript.find(transcript_id)
      # mark the record as processing, so that other processors will not
      # pick it up
      transcript.update_column("pickedup_for_voicebase_processing_at", Time.zone.now)
      res = Voicebase::Client.new.check_progress(transcript.voicebase_media_id)
      status = JSON.parse res.body
      if status["errors"]
        #TODO: upload to bugsnag
      else
        transcript.update_column("voicebase_status", status["progress"]["status"])
      end
    end

    def self.process_transcript(transcript_id)
      transcript = Transcript.find(transcript_id)

      if transcript.voicebase_status == "completed"
        str = get_transcript(transcript_id)
        imp = VoiceBase::ImportSrtTranscripts.new(project_id: ENV["PROJECT_ID"])
        imp.update_from_voicebase(transcript, str)
        transcript.update_column("voicebase_processing_completed_at", Time.zone.now)
      else
        # reset back for next time
        transcript.update_column("pickedup_for_voicebase_processing_at", nil)
      end
    end

    def self.get_transcript(transcript_id)
      transcript = Transcript.find(transcript_id)
      res = Voicebase::Client.new.get_transcript(transcript.voicebase_media_id)

      if res.code == "200"
        res.body
      else
        #TODO: upload to bugsnag
      end
    end
  end
end

