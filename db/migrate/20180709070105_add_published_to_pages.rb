# frozen_string_literal: true

class AddPublishedToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :published, :boolean, default: false
  end
end
