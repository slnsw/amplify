# frozen_string_literal: true

class AddVerifyStatsToTranscripts < ActiveRecord::Migration[7.0]
  def change
    add_column :transcripts, :percent_reviewing, :integer, null: false, default: 0
    add_column :transcripts, :lines_reviewing, :integer, null: false, default: 0
    add_column :transcripts, :users_contributed, :integer, null: false, default: 0
  end
end
