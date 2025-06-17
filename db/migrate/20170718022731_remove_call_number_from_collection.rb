# frozen_string_literal: true

class RemoveCallNumberFromCollection < ActiveRecord::Migration[7.0]
  def change
    remove_column :collections, :call_number, :string
  end
end
