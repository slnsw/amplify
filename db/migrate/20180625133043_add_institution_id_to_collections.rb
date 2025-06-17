# frozen_string_literal: true

class AddInstitutionIdToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :institution_id, :integer
  end
end
