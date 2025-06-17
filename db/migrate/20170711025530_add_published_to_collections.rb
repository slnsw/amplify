# frozen_string_literal: true

class AddPublishedToCollections < ActiveRecord::Migration[7.0]
  def change
    add_column(:collections, :published_at, :datetime, default: nil)
  end
end
