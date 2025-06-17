# frozen_string_literal: true

class AddEditsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :lines_edited, :integer, null: false, default: 0
  end
end
