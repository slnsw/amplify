# frozen_string_literal: true

class AddGuidToInstitutions < ActiveRecord::Migration[7.0]
  def change
    add_column :institutions, :guid, :string

    Institution.where(guid: nil).find_each(&:save)
  end
end
