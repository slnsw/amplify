# frozen_string_literal: true

class AddImageToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :image, :string
  end
end
