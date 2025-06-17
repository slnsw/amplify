# frozen_string_literal: true

class AddPublishedAtToTranscrnscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :published_at, :datetime, default: nil
  end
end
