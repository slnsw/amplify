# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.text :content
      t.string :page_type

      t.timestamps
    end
  end
end
