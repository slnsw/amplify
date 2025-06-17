# frozen_string_literal: true

class AddNewTitlesForTranscript < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :audio_item_url_title, :string, default: 'View audio in Library catalogue'
    add_column :transcripts, :image_item_url_title, :string, default: 'View image in Library catalogue'
  end
end
