# frozen_string_literal: true

class AddInstitutionsToUsers < ActiveRecord::Migration[5.2]
  def change
    # admins will not have an institute
    add_column :users, :institution_id, :integer, default: nil
  end
end
