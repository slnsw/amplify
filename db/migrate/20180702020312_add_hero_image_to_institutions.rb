# frozen_string_literal: true

class AddHeroImageToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :hero_image, :string
  end
end
