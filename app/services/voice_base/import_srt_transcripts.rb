# frozen_string_literal: true

module VoiceBase
  # SRT Transcript importer.
  class ImportSrtTranscripts
    def self.call(project_id:)
      new(project_id: project_id).send(:call)
    end

    def initialize(project_id:)
      @project_id = project_id
    end

    # Process a single transcript.
    # @param int transcript_id
    def process_single(transcript_id)
      transcript = Transcript.find(transcript_id)
      load_from_file(transcript) if transcript
    end

    def update_from_voicebase(transcript, contents)
      update_records(transcript, contents.lines)
    end

    private

    def call
      # Retrieve empty transcripts that have VoiceBase as their vendor.
      transcripts = Transcript.getForDownloadByVendor("voice_base", @project_id)
      puts "Retrieved #{transcripts.count} empty transcripts from collections \
      with VoiceBase as their vendor."

      transcripts.find_each { |transcript| load_from_file(transcript) }
    end

    def transcript_file_path(transcript)
      Rails.root.join("project", @project_id, "transcripts", "voice_base",
                      "#{transcript.vendor_identifier}.srt")
    end

    # Read lines from a single transcript.
    # @param Transcript transcript
    def read_lines_from_file(transcript)
      if transcript.script.file.nil?
        fp = transcript_file_path(transcript)
        unless File.exist?(fp)
          puts "Couldn't find transcript in project folder for Transcript \
          ##{transcript.id} at #{fp}."
          return []
        end
        File.read(fp).lines
      else
        transcript.script.file.read.lines
      end
    end

    # Load a transcript from a file.
    def load_from_file(transcript)
      contents = read_lines_from_file(transcript)
      update_records(transcript, contents)
    end

    def update_records(transcript, contents)
      transcript_lines = get_transcript_lines_from_file(transcript, contents)
      ok = ingest_transcript_lines(transcript, transcript_lines)

      debug = "No lines read from transcript #{transcript.uid}."
      if ok
        debug = "Created #{transcript_lines.length} lines from \
        transcript #{transcript.uid}."
      end
      puts debug
    end

    # Ingest processed lines into the transcript.
    def ingest_transcript_lines(transcript, transcript_lines)
      return nil if transcript_lines.blank?

      TranscriptLine.where(transcript_id: transcript.id).destroy_all
      TranscriptLine.create!(transcript_lines)
      transcript.update!(
        lines: transcript_lines.count,
        transcript_status: downloaded_state,
        duration: transcript_lines.last[:end_time] / 1000,
        vendor_audio_urls: [],
        transcript_retrieved_at: DateTime.now,
      )
    end

    # Default downloaded state for transcript.
    def downloaded_state
      TranscriptStatus.find_by(name: :transcript_downloaded)
    end

    # Parse transcript lines.
    def get_transcript_lines_from_file(transcript, contents)
      VoiceBase::SrtParser.new(transcript.id, contents).lines
    end

    # Convert a timestamp to milliseconds.
    def convert_time_to_milliseconds(time)
      ((Time.strptime(time, "%H:%M:%S,%L") - Time.now.at_midnight) * 1000).to_i
    end
  end
end
