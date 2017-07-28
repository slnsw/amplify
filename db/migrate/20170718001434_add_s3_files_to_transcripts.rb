class AddS3FilesToTranscripts < ActiveRecord::Migration
  def change
    add_column :transcripts, :image, :string, default: nil
    add_column :transcripts, :audio, :string, default: nil
    add_column :transcripts, :script, :string, default: nil
  end
end
