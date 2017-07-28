class AddImageToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :image, :string, default: nil
  end
end
