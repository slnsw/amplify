# frozen_string_literal: true

class AddPublishToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :publish, :boolean, default: false
  end
end
