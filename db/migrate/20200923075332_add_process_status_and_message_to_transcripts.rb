# frozen_string_literal: true

class AddProcessStatusAndMessageToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :process_status, :string
    add_column :transcripts, :process_message, :string
  end
end
