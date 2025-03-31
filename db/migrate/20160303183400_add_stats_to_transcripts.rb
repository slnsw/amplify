class AddStatsToTranscripts < ActiveRecord::Migration[7.0]
  def change
    add_column :transcripts, :percent_completed, :integer, :null => false, :default => 0
    add_column :transcripts, :lines_completed, :integer, :null => false, :default => 0
    add_column :transcripts, :percent_edited, :integer, :null => false, :default => 0
    add_column :transcripts, :lines_edited, :integer, :null => false, :default => 0
  end
end
