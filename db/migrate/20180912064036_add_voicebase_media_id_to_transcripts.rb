# frozen_string_literal: true

class AddVoicebaseMediaIdToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :voicebase_media_id, :string
  end
end
