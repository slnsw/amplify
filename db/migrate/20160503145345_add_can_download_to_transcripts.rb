class AddCanDownloadToTranscripts < ActiveRecord::Migration[7.0]
  def change
    add_column :transcripts, :can_download, :integer, :null => false, :default => 1
  end
end
