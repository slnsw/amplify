class CreateTranscriptLines < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_lines do |t|
      t.integer :transcript_id, :null => false, :default => 0
      t.integer :start_time, :null => false, :default => 0
      t.integer :end_time, :null => false, :default => 0
      t.integer :speaker_id, :null => false, :default => 0
      t.string :original_text, :null => false, :default => ""
      t.string :text, :null => false, :default => ""
      t.integer :sequence, :null => false, :default => 0
      t.integer :transcript_status_id, :null => false, :default => 1
      t.string :notes

      t.timestamps null: false
    end

    add_index :transcript_lines, :transcript_id
    add_index :transcript_lines, :speaker_id
    add_index :transcript_lines, [:transcript_id, :sequence], :unique => true
    add_index :transcript_lines, :transcript_status_id
  end
end
