include Rails.application.routes.url_helpers
default_url_options[:only_path] = true

namespace :sample do
  # Usage:
  #     rake sample:seed
  #     rake sample:seed[1]
  desc "Seed a transcript for testing various stages of transcripts"
  task :seed, [:edits] => :environment do |_task, args|
    do_edits = (args[:edits] || false)

    # seed users

    # seed transcript
    transcript = seedTranscript

    # seed speakers
    speakers = seedSpeakers(transcript)

    # seed lines
    lines = seedLines(transcript)

    # delete flags
    deleteFlags(transcript)

    deleteEdits(transcript)
    if do_edits
      seedEdits(transcript, lines)
    end

    puts "Sample transcript can be accessed via: #{transcript_url(transcript.uid)}"
  end

  def deleteEdits(transcript)
    TranscriptEdit.where(transcript_id: transcript.id).destroy_all
    TranscriptSpeakerEdit.where(transcript_id: transcript.id).destroy_all
  end

  def deleteFlags(transcript)
    Flag.where(transcript_id: transcript.id).destroy_all
  end

  def seedEdit(attributes)
    TranscriptEdit.create attributes
  end

  def seedEdits(_transcript, lines)
    seedEditsEditing(lines[0]) if lines[0]
    seedEditsReviewing(lines[2]) if lines[2]
    seedEditsCompleted(lines[3]) if lines[3]
  end

  def seedEditsEditing(line)
    # Just one edit
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "one_1", text: "[laughter] Oh, really?" })
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "one_2", text: "[laughing] Oh, really?" })

    line.recalculate
  end

  def seedEditsReviewing(line)
    # Many edits, none agree
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "two_1", text: "Oh. April Fourth, two thousand sixteen" })
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "two_2", text: "On, um, April fourth, 2016" })
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "two_3", text: "On April 4th, 2016" })

    line.recalculate
  end

  def seedEditsCompleted(line)
    # Many edits, all agree
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "three_1", text: "Can you tell me more?" })
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "three_2", text: "can you tell me more?" })
    seedEdit({ transcript_id: line.transcript_id, transcript_line_id: line.id, session_id: "three_3", text: "Can you tell me more" })

    line.recalculate
  end

  def seedLine(attributes)
    line = TranscriptLine.find_or_initialize_by({ transcript_id: attributes[:transcript_id], sequence: attributes[:sequence] })
    line.update(attributes)
    line
  end

  def seedLines(transcript)
    puts "Seeding transcript lines..."

    lines = []
    lines << seedLine({ transcript_id: transcript.id, sequence: 0, start_time: 2, end_time: 2430, original_text: "oh really", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 1, start_time: 2445, end_time: 4480, original_text: "and we want live", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 2, start_time: 4490, end_time: 8230, original_text: "In april fourth two thousand and sixteen", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 3, start_time: 8604, end_time: 10273, original_text: "can you tell me more", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 4, start_time: 10276, end_time: 14560, original_text: "yah care to start", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 5, start_time: 14793, end_time: 16343, original_text: "why do want to show", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 6, start_time: 16711, end_time: 19168, original_text: "it's a community driven project we start with", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines << seedLine({ transcript_id: transcript.id, sequence: 7, start_time: 19110, end_time: 21334, original_text: "with speeched text generation transcripts", guess_text: "", text: "", transcript_line_status_id: 1, speaker_id: 0, flag_count: 0 })
    lines
  end

  def seedSpeaker(attributes)
    speaker = Speaker.find_or_create_by(name: attributes[:name])
    # speaker.update(attributes)
    speaker
  end

  def seedSpeakers(transcript)
    speakers = []
    speakers << seedSpeaker({ name: "Brian" })
    speakers << seedSpeaker({ name: "Willa" })

    speakers.each do |speaker|
      ts = TranscriptSpeaker.find_or_initialize_by(speaker_id: speaker.id, transcript_id: transcript.id)
      ts.update(project_uid: transcript.project_uid)
    end
  end

  def seedTranscript
    puts "Seeding transcript.."

    attributes = { uid: "sample-transcript", title: "Together We Listen Sample", audio_url: "/audio/twl_sample.mp3", lines: 8, duration: 22, transcript_status_id: 1, project_uid: "sample-project", lines_completed: 0, lines_edited: 0, percent_completed: 0, percent_edited: 0 }
    transcript = Transcript.find_or_initialize_by(uid: attributes[:uid])
    transcript.update(attributes)
    transcript
  end
end
