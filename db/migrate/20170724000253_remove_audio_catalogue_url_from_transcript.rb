class RemoveAudioCatalogueUrlFromTranscript < ActiveRecord::Migration[7.0]
  def change
    remove_column :transcripts, :audio_catalogue_url, :string
  end
end
