# frozen_string_literal: true

class AddHierarchyBypassToUserRole < ActiveRecord::Migration[7.0]
  def change
    add_column :user_roles, :transcribing_role, :string, default: 'registered_user'
  end
end
