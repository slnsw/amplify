# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :collections do |t|
      t.string :uid, null: false, default: ''
      t.string :title
      t.text :description
      t.string :url
      t.string :image_url
      t.integer :vendor_id, null: false, default: 0
      t.string :vendor_identifier, null: false, default: ''

      t.timestamps null: false
    end

    add_index :collections, :uid, unique: true
    add_index :collections, :vendor_id
    add_index :collections, %i[vendor_id vendor_identifier], unique: true
  end
end
