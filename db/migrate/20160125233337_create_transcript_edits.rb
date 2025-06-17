# frozen_string_literal: true

class CreateTranscriptEdits < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_edits do |t|
      t.integer :transcript_id, null: false, default: 0
      t.integer :transcript_line_id, null: false, default: 0
      t.integer :user_id, null: false, default: 0
      t.string :session_id, null: false, default: ''
      t.string :text
      t.integer :weight, null: false, default: 0

      t.timestamps null: false
    end

    add_index :transcript_edits, :transcript_id
    add_index :transcript_edits, :transcript_line_id
    add_index :transcript_edits, :user_id
    add_index :transcript_edits, :session_id
    add_index :transcript_edits, %i[session_id transcript_line_id], unique: true
  end
end
