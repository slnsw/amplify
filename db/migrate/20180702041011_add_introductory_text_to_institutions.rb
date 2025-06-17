# frozen_string_literal: true

class AddIntroductoryTextToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :introductory_text, :text
  end
end
