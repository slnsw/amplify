class RemoveAudioCatalogueUrlFromTranscript < ActiveRecord::Migration
  def change
    remove_column :transcripts, :audio_catalogue_url, :string
  end
end
