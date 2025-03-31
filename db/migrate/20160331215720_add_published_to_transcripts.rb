class AddPublishedToTranscripts < ActiveRecord::Migration[7.0]
  def change
    add_column :transcripts, :is_published, :integer, :null => false, :default => 1
  end
end
