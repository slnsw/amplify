require 'open-uri'
require 'shellwords'
require 'tempfile'

module Azure
  class SpeechToTextJob < ApplicationJob
    queue_as :default

    def perform(transcript_id)
      transcript = Transcript.find transcript_id
      return if transcript.process_started?

      # Use OpenURI to download the audio file instead of CarrierWave cache
      file = download_via_open_uri(transcript.audio)

      transcript.update_columns(
        process_status: :started,
        process_message: nil,
        process_started_at: Time.current
      )

      # Usage of Tempfile object is still backwards compatible with the old implementation
      # Hence, No changes are required in the Azure::SpeechToTextService class
      speech_to_text = Azure::SpeechToTextService.new(file: file.path).recognize
      lines = speech_to_text.lines
      wav_file = File.open(speech_to_text.wav_file_path)

      if transcript.transcript_lines.count == 0
        ActiveRecord::Base.transaction do
          transcript.transcript_lines.clear
          lines.each do |line_attrbitues|
            transcript.transcript_lines.create(line_attrbitues)
          end
          transcript.update_columns(
            lines: lines.length,
            duration: `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{Shellwords.escape(file.path)}`.to_i
          )
        end
      end

      transcript.update(audio: wav_file)
      transcript.update_columns(
        process_status: :completed,
        process_message: nil,
        process_completed_at: Time.current
      )
    rescue Exception => e
      transcript.update_columns(
        process_status: :failed,
        process_message: e.message
      )
      Bugsnag.notify e
    ensure
      if file&.respond_to?(:close) && file.respond_to?(:unlink)
        file.close unless file.closed?
        file.unlink
      end

      if speech_to_text&.wav_file_path && File.exist?(speech_to_text&.wav_file_path.to_s)
        File.delete speech_to_text&.wav_file_path
      end
    end

    def download_via_open_uri(audio)
      # Primary approach to download the audio file. Since the upgrade from Carrierwave 2 -> 3, the cache_stored_file!
      # method is not working as expected. Hence, we are using the OpenURI method to download the audio file.

      # Download the remote file to a Tempfile object instead of using the Carrierwave cache
      file = Tempfile.new(['audio', File.extname(audio.url)])
      file.binmode
      URI.open(audio.url) do |remote|
        file.write(remote.read)
      end
      file.flush
      file.rewind

      file # Return the Tempfile object, not just the path
    rescue StandardError => e
      Rails.logger.error "=============== Failed to download audio file: #{e.message} ==============="
      file&.close
      file&.unlink
      raise e
    end
  end
end
