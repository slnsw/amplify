module DashboardHelper
  def edited_info(edits)
    time = display_time(edits.count * Transcript.seconds_per_line)
    "<p>You have edited <strong>#{edits.count}</strong> lines in <strong>#{edits.map(&:transcript_id).uniq.count}</strong> transcripts and listened to about <strong>#{time}</strong> of audio!</p>"
  end

  def group_edits_by_transcripts(edits)
    list = {}

    edits.each do |edit|
      if list[edit.transcript_id]
        list[edit.transcript_id][:edits] << edit
      else
        hash = {
          transcript: edit.transcript,
          edits: [edit]
        }
        list[edit.transcript_id] = hash
      end
    end
    list
  end

  def time_in_seconds(time)
    display_time(time.to_i * Transcript.seconds_per_line)
  end

  def edits_min_display
    7 # assign to environment variable maybe?, so there will be no code change if client decides to change the minimum display
  end
end
