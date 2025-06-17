# frozen_string_literal: true

json.array!(@collections) do |collection|
  json.extract! collection, :id, :uid, :title, :library_catalogue_title, :description, :url, :image_url
  json.path collection_path(collection)
end
