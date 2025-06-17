# frozen_string_literal: true

module VoiceBase
  class VoicebaseApiService
    attr_accessor :transcript

    # Upload audio file to Voicebase for processing.
    def self.upload_media(transcript_id)
      transcript = Transcript.find(transcript_id)

      res = Voicebase::Client.new.upload_media(upload_url(transcript))
      status = JSON.parse(res.body)
      if status['errors']
        Bugsnag.notify("Could not do Voicebase audio upload for transcript #{transcript_id}: #{status['errors']}")
      else
        transcript.update_column('voicebase_media_id', status['mediaId'])
      end
    end

    # Specify the audio file URL to upload.
    # NOTE: this code is to test the functionality locally
    #      otherwise, since the file is not uploading to aws
    #      VoiceBase upload will not work as it cannot access
    #      the image url.
    def self.upload_url(transcript)
      if Rails.env.development?
        return 'https://slnsw-amplify.s3.amazonaws.com/collections_v2/snowymountain_bushfires/audio/mloh307-0001-0004-s002-m.mp3'
      end

      transcript.audio_url
    end

    # Check progress of Voicebase processing.
    def self.check_progress(transcript_id)
      transcript = Transcript.find(transcript_id)

      # If it hasn't been uploaded to Voicebase yet,
      # better do it first.
      unless transcript.voicebase_media_id
        if transcript.audio_url
          Bugsnag.notify("Could not do Voicebase processing for transcript #{transcript_id}: Audio content not uploaded yet, rescheduling.")
          VoiceBaseUploadJob.perform_later(transcript_id)
        else
          Bugsnag.notify("Could not do Voicebase processing for transcript #{transcript_id}: No audio content available for processing.")
        end
        return false
      end

      # Mark the record as processing, so that other processors
      # will not pick it up.
      transcript.update_column('process_started_at', Time.zone.now)
      res = Voicebase::Client.new.check_progress(transcript.voicebase_media_id)
      status = JSON.parse(res.body)
      if status['errors']
        Bugsnag.notify("Voicebase processing errors for transcript #{transcript_id}: #{status['errors']}")
        false
      else
        transcript.update_column('process_status', status['progress']['status'])
      end
    end

    # Download completed transcript from Voicebase, and import.
    def self.process_transcript(transcript_id)
      transcript = Transcript.find(transcript_id)

      if transcript.process_status == 'completed'
        str = get_transcript(transcript_id)
        if str
          imp = VoiceBase::ImportSrtTranscripts.new(project_id: ENV['PROJECT_ID'])
          imp.update_from_voicebase(transcript, str)
          transcript.update_column('process_completed_at', Time.zone.now)
          return
        end
      end

      # reset back for next time
      transcript.update_column('process_started_at', nil)
    end

    # Download completed transcript from Voicebase.
    def self.get_transcript(transcript_id)
      transcript = Transcript.find(transcript_id)
      unless transcript.voicebase_media_id
        transcript.voicebase_upload
        return nil
      end

      res = Voicebase::Client.new.get_transcript(transcript.voicebase_media_id)

      if res.code == '200'
        res.body
      else
        Bugsnag.notify("Voicebase errors when reading transcript #{transcript_id}")
      end
    end
  end
end
