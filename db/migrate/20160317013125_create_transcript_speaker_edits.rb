# frozen_string_literal: true

class CreateTranscriptSpeakerEdits < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_speaker_edits do |t|
      t.integer :transcript_id, null: false, default: 0
      t.integer :transcript_line_id, null: false, default: 0
      t.integer :user_id, null: false, default: 0
      t.string :session_id, null: false, default: ''
      t.integer :speaker_id, null: false, default: 0

      t.timestamps null: false
    end

    add_index :transcript_speaker_edits, :transcript_line_id
    add_index :transcript_speaker_edits, :user_id
    add_index :transcript_speaker_edits, %i[session_id transcript_line_id], unique: true, name: 'index_transcript_speaker_edits_on_session_id_and_line_id'
  end
end
