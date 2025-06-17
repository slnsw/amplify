# frozen_string_literal: true

class AddVoicebaseProcessingCompletedAtToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :voicebase_processing_completed_at, :datetime
  end
end
