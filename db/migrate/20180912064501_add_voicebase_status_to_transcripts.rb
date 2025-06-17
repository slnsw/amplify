# frozen_string_literal: true

class AddVoicebaseStatusToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :voicebase_status, :string
  end
end
