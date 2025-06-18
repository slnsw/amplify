# frozen_string_literal: true

module VoiceBase
  # SRT Transcript importer.
  class SrtParser
    def initialize(transcript_id = nil, raw_lines = [])
      @transcript_id = transcript_id
      @raw_lines = raw_lines
      @transcript_lines = []
      setup_state_machine
      setup_regex
      run
    end

    # Use line_number and line_temp to store the current state.
    def setup_state_machine
      @line_number = 1
      reset_reading
    end

    # Store regexes for later.
    def setup_regex
      @to_from_match = /(\d+:\d+:\d+,\d+) --> (\d+:\d+:\d+,\d+)/
      @whitespace_only = /^\s*$/
    end

    # Insert the finalised SRT line into the transcript.
    def insert_into_transcript
      @transcript_lines << {
        transcript_id: @transcript_id,
        start_time: @line_temp[:from],
        end_time: @line_temp[:to],
        original_text: @line_temp[:lines].join(" "),
        sequence: (@line_number - 1),
      }
      @line_number += 1
    end

    # Reset reading state to default.
    def reset_reading
      @line_temp = {
        reading: false,
        from: nil,
        to: nil,
        lines: [],
      }
    end

    # We have start and end timestamps; start reading lines of text.
    def start_reading(from_text, to_text)
      @line_temp = {
        reading: true,
        from: convert_time_to_milliseconds(from_text),
        to: convert_time_to_milliseconds(to_text),
        lines: [],
      }
    end

    # Parse all available lines.
    def run
      run_newline while @raw_lines.any?

      # When we've finished parsing the document,
      # if we were still reading content,
      # read that line into the transcript.
      insert_into_transcript if @line_temp[:reading]
    end

    # Parse a single line.
    def run_newline
      newline = @raw_lines.shift

      # First, we test if the new line contains from/to timestamps,
      # and if so, start reading.
      try_match_to_from = @to_from_match.match(newline)
      if try_match_to_from.nil?
        newline_might_have_content(newline)
      else
        newline_has_from_to(try_match_to_from)
      end
    end

    # If a valid match for the timestamp, we need to save all
    # existing line data, and start a new line.
    # If we're still reading, add the existing data
    # to the transcript right away.
    def newline_has_from_to(from_to)
      insert_into_transcript if @line_temp[:reading]
      start_reading(from_to[1], from_to[2])
    end

    # Otherwise, we add more content to the existing line,
    # but only if we are actively reading.
    def newline_might_have_content(newline)
      return unless @line_temp[:reading]

      if !newline.empty? && @whitespace_only !~ newline
        # Add the new line to the list of ingested lines.
        @line_temp[:lines] << newline
      else
        # The current line is whitespace or empty.
        # Add the ingested line to the transcript,
        # and carry on.
        insert_into_transcript
        reset_reading
      end
    end

    # Get the rendered transcript lines.
    def lines
      @transcript_lines
    end

    # Convert a timestamp to milliseconds.
    def convert_time_to_milliseconds(time)
      ((Time.strptime(time, "%H:%M:%S,%L") - Time.now.at_midnight) * 1000).to_i
    end
  end
end
