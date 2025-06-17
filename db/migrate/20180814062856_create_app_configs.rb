# frozen_string_literal: true

class CreateAppConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :app_configs do |t|
      t.string :app_name
      t.boolean :show_theme, default: false
      t.boolean :show_institutions, default: false
    end
  end
end
