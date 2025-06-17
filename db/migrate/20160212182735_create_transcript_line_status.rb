# frozen_string_literal: true

class CreateTranscriptLineStatus < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_line_statuses do |t|
      t.string :name, null: false, default: ''
      t.integer :progress, null: false, default: 0
      t.string :description
    end

    add_index :transcript_line_statuses, :name, unique: true
    rename_column :transcript_lines, :transcript_status_id, :transcript_line_status_id
  end
end
