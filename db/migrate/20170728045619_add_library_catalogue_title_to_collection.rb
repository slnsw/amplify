class AddLibraryCatalogueTitleToCollection < ActiveRecord::Migration[7.0]
  def change
    add_column :collections, :library_catalogue_title, :string, default: ""
  end
end
