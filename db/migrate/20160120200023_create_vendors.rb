# frozen_string_literal: true

class CreateVendors < ActiveRecord::Migration[7.0]
  def change
    create_table :vendors do |t|
      t.string :uid, null: false, default: ''
      t.string :name
      t.string :description
      t.string :url
      t.string :image_url

      t.timestamps null: false
    end

    add_index :vendors, :uid, unique: true
  end
end
