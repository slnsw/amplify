class AddPublishedToCollections < ActiveRecord::Migration
  def change
    add_column(:collections, :published_at, :datetime, default: nil)
  end
end
