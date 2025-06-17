# frozen_string_literal: true

class AddDeletedToEdit < ActiveRecord::Migration[7.0]
  def change
    add_column :transcript_edits, :is_deleted, :integer, null: false, default: 0
  end
end
