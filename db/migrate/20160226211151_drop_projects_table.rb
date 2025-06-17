# frozen_string_literal: true

class DropProjectsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :projects
  end
end
