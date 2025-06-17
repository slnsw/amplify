# frozen_string_literal: true

class AddCollectionUrlTitleToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :collection_url_title, :string, default: ' View in Library catalogue'
  end
end
