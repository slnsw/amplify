class AddLibraryCatalogueTitleToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :library_catalogue_title, :string, default: ""
  end
end
