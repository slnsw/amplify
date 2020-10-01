require 'open3'

module Azure
  class SpeechToTextService
    include ActiveModel::Model
    attr_accessor :file

    def recognize
      convert_audio_to_wav
      JSON.parse(transcripts_from_sdk).tap { cleanup }
    rescue Exception => e
      cleanup
      raise e
    end

    protected

    def extension
      File.extname(file)
    end

    # converted audio file path.
    # the file needs to be removed once this service is completed.
    # @see #cleanup
    def wav_file
      @wav_file ||= file.to_s.gsub(extension, ".#{SecureRandom.uuid}.wav")
    end

    # Convert the file to what azure speech-to-text javascript SDK requires
    # @see speech-to-text.js
    def convert_audio_to_wav
      stdout, stderr, status =
        Open3.capture3("ffmpeg", "-i", file.to_s, "-ac", "1", "-ar", "8000", wav_file)
      raise Exception, stderr unless status.success?
      Rails.logger.debug("--- transcripts_from_sdk ---")
      Rails.logger.debug(wav_file.size)
    end

    def transcripts_from_sdk
      stdout, stderr, status =
        Open3.capture3(
          ENV.to_h.slice("SPEECH_TO_TEXT_KEY", "SPEECH_TO_TEXT_REGION"),
          "node", Rails.root.join("speech-to-text.js").to_s, wav_file
        )
      Rails.logger.debug("--- transcripts_from_sdk ---")
      Rails.logger.debug(stdout)
      Rails.logger.debug(stderr)
      raise Exception, stderr.presence || stdout unless status.success?
      stdout
    end

    def cleanup
      File.delete wav_file if File.exist? wav_file
    end
  end
end
