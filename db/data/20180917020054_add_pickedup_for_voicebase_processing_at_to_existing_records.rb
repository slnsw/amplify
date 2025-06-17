# frozen_string_literal: true

class AddPickedupForVoicebaseProcessingAtToExistingRecords < SeedMigration::Migration
  def up
    Transcript.voicebase.update_all(pickedup_for_voicebase_processing_at: Time.zone.now)
  end

  def down
    Transcript.voicebase.update_all(pickedup_for_voicebase_processing_at: nil)
  end
end
