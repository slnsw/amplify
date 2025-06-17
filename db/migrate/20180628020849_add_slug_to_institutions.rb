# frozen_string_literal: true

class AddSlugToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :slug, :string
    add_index :institutions, :slug
  end
end
