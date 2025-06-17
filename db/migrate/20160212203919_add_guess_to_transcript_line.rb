# frozen_string_literal: true

class AddGuessToTranscriptLine < ActiveRecord::Migration[7.0]
  def change
    add_column :transcript_lines, :guess_text, :string, null: false, default: ''
  end
end
