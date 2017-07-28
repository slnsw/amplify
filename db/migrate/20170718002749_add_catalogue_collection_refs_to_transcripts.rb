class AddCatalogueCollectionRefsToTranscripts < ActiveRecord::Migration
  def change
    add_column :transcripts, :audio_catalogue_url, :string, default: ""
    add_column :transcripts, :image_caption, :string, default: ""
    add_column :transcripts, :image_catalogue_url, :string, default: ""
  end
end
