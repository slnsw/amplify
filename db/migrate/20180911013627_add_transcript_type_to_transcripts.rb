# frozen_string_literal: true

class AddTranscriptTypeToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :transcript_type, :integer, default: 0
  end
end
