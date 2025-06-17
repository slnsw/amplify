# frozen_string_literal: true

class PublishExistingCollections < ActiveRecord::Migration[5.2]
  def change
    # with the introduction of the new publish functionality
    # existing collections needs to be published
    Collection.unscoped.all.map(&:publish!)
  end
end
