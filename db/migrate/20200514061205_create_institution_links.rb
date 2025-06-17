# frozen_string_literal: true

class CreateInstitutionLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :institution_links do |t|
      t.references :institution
      t.string :title
      t.string :url
      t.integer :position

      t.timestamps
    end
  end
end
