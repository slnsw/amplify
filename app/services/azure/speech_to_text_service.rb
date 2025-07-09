require 'open3'

module Azure
  class SpeechToTextService
    include ActiveModel::Model
    attr_accessor :file

    def recognize
      convert_audio_to_wav

      result = OpenStruct.new
      result.lines = JSON.parse(transcripts_from_sdk)
      result.wav_file_path = wav_file

      result
    rescue Exception => e
      cleanup
      raise e
    end

    protected

    def extension
      File.extname(file)
    end

    def filename
      File.basename(file)
    end

    # converted audio file path.
    # the file needs to be removed once this service is completed.
    # @see #cleanup
    def wav_file
      # store it in /tmp folder as it has much larger space
      @wav_file ||= Pathname.new("/tmp").join(
        filename.gsub(extension, ".#{SecureRandom.uuid}.wav")
      ).to_s
    end

    # Convert the file to what azure speech-to-text javascript SDK requires
    # @see speech-to-text.js
    def convert_audio_to_wav
      stdout, stderr, status =
        Open3.capture3("ffmpeg", "-i", file.to_s, "-ac", "1", "-ar", "16000", wav_file)
      raise Exception, stderr.to_s unless status.success?
      Rails.logger.debug("--- convert_audio_to_wav ---")
      Rails.logger.debug(File.size wav_file) if File.exist? wav_file
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
      error_message = (stderr.presence || stdout).to_s
      raise Exception, error_message unless status.success?
      stdout
    end

    def cleanup
      File.delete wav_file if File.exist? wav_file
    end
  end
end
