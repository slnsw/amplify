class MakeExistingTranscriptsManual < SeedMigration::Migration
  def up
    # update the existing transcripts to be manual uploads
    Transcript.update_all(transcript_type: 1)
  end

  def down
    Transcript.update_all(transcript_type: 0)
  end
end
