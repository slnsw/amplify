# frozen_string_literal: true

class AddAdminAccessToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :admin_access, :boolean, default: false
  end
end
