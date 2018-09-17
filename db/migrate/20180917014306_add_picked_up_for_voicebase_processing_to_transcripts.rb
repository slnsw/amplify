class AddPickedUpForVoicebaseProcessingToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :pickedup_for_voicebase_processing_at, :datetime
  end
end
