class AddVoicebaseStatusToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :voicebase_status, :string
  end
end
