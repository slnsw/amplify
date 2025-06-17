# frozen_string_literal: true

class CreateInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      t.string :name
      t.timestamps
    end
  end
end
