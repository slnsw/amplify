# frozen_string_literal: true

namespace :transcript_lines do
  # Usage:
  #     rake transcript_lines:recalculate[0,0,1]
  #     rake transcript_lines:recalculate[0,'adrian-wagner-nxr3fk']
  #     rake transcript_lines:recalculate[56]
  #     rake transcript_lines:recalculate
  desc "Recalculate a line, a transcript's lines, or all lines"
  task :recalculate, %i[line_id transcript_uid original_text] => :environment do |_task, args|
    args.with_defaults line_id: 0
    args.with_defaults transcript_uid: false
    args.with_defaults original_text: false

    lines = []
    line_id = args[:line_id].to_i

    if line_id.positive?
      lines = TranscriptLine.where(id: line_id)

    elsif args[:original_text].present?
      lines = TranscriptLine.where('text = original_text')

    elsif args[:transcript_uid].present?
      transcript = Transcript.find_by(uid: args[:transcript_uid])
      lines = TranscriptLine.getEditedByTranscriptId(transcript.id)

    else
      lines = TranscriptLine.getEdited
    end

    lines.each(&:recalculate)
  end

  # rake transcript_lines:find_max_overlap
  task find_max_overlap: :environment do |_task, _args|
    transcripts = Transcript.where('lines > 0')
    overlap_max = 0
    transcript_max = nil

    transcripts.each do |transcript|
      lines = TranscriptLine.where(transcript_id: transcript.id)
      previous_line = nil
      overlaps = []
      lines.each do |line|
        if previous_line
          overlap = previous_line.end_time - line.start_time
          overlaps << overlap
        end
        previous_line = line
      end
      next unless overlaps.length.positive?

      sum = overlaps.inject(0) { |sum, x| sum + x }
      avg = sum / overlaps.length
      if avg > overlap_max
        overlap_max = avg
        transcript_max = transcript
      end
    end

    puts "Max transcript overlap: #{transcript_max.uid} #{transcript_max.title} (#{overlap_max})" if transcript_max
  end
end
