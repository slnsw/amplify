class CreateTranscriptSpeakers < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_speakers do |t|
      t.integer :speaker_id, :null => false, :default => 0
      t.integer :transcript_id, :null => false, :default => 0
      t.integer :collection_id, :null => false, :default => 0
      t.string :project_uid, :null => false, :default => ''

      t.timestamps null: false
    end

    add_index :transcript_speakers, [:speaker_id, :transcript_id], :unique => true
  end
end
