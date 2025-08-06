require 'open-uri'
require 'shellwords'
require 'tempfile'

module Azure
  class SpeechToTextJob < ApplicationJob
    queue_as :default

    def perform(transcript_id)
      transcript = Transcript.find transcript_id
      return if transcript.process_started?

      begin
        # Use OpenURI to download the audio file as primary approach.
        file = download_via_open_uri(transcript.audio)
        Rails.logger.info "=============== Successfully downloaded via OpenURI: #{file.path} ==============="
        Rails.logger.info "=============== File Exists in Local Directory: #{File.exist?(file.path)} ==============="
      rescue StandardError => e
        Rails.logger.error "=============== Failed to download audio file via OPENURI: #{e.message} ==============="

        file = download(transcript.audio)
        Rails.logger.info "=============== Successfully downloaded via CarrierWave cache: #{file} ==============="
        Rails.logger.info "=============== File Exists in Local Directory: #{File.exist?(file)} ==============="
      end

      transcript.update_columns(
        process_status: :started,
        process_message: nil,
        process_started_at: Time.current
      )

      # Usage of Tempfile object is still backwards compatible with the old implementation
      # Hence, No changes are required in the Azure::SpeechToTextService class
      speech_to_text = Azure::SpeechToTextService.new(file: file.is_a?(String) ? file : file.path).recognize
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
            duration: `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{Shellwords.escape(file.to_s)}`.to_i
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
      # Handle cleanup for both string paths and Tempfile objects
      if file
        if file.respond_to?(:close) && file.respond_to?(:unlink)
          # Tempfile object - use tempfile cleanup methods
          file.close unless file.closed?
          file.unlink
        elsif file.is_a?(String) && File.exist?(file)
          # String path - use regular file deletion
          File.delete(file)
        end
      end

      if speech_to_text&.wav_file_path && File.exist?(speech_to_text&.wav_file_path.to_s)
        File.delete speech_to_text&.wav_file_path
      end
    end

    # rubocop:disable Metrics/AbcSize
    # Reference: https://github.com/carrierwaveuploader/carrierwave/wiki/How-to%3A-Recreate-and-reprocess-your-files-stored-on-fog
    def download(audio)
      # TODO: Remove or mark for deprecation after testing
      # Step 1: Download S3 file to local cache
      audio.cache_stored_file!

      # Step 2: Retrieve the cached file as a SanitizedFile (this converts Fog::File to SanitizedFile)
      audio.retrieve_from_cache!(audio.cache_name)

      # Step 3: Now we can access the local file path
      local_path = audio.file.path

      # Check if file actually exists on disk
      raise StandardError, "CarrierWave cached file does not exist: #{local_path}" unless File.exist?(local_path)

      return local_path if local_path.to_s.size <= 150

      # If the path is too long, create a shorter path
      extension = audio.file.filename.split('.').last
      new_random_name = SecureRandom.hex
      new_name = Rails.public_path.join(audio.cache_dir, "#{new_random_name}.#{extension}")

      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(new_name))

      File.rename(local_path, new_name)

      new_name
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
      Rails.logger.error '=============== From download_alternative (Using OpenURI)! ==============='
      file&.close
      file&.unlink
      raise e
    end
    # rubocop:enable Metrics/AbcSize
  end
end
