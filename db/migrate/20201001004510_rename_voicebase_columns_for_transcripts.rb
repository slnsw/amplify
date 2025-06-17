# frozen_string_literal: true

class RenameVoicebaseColumnsForTranscripts < ActiveRecord::Migration[5.2]
  def change
    remove_column :transcripts, :process_status
    rename_column :transcripts, :voicebase_status, :process_status
    rename_column :transcripts, :voicebase_processing_completed_at, :process_completed_at
    rename_column :transcripts, :pickedup_for_voicebase_processing_at, :process_started_at
  end
end
