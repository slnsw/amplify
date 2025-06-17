# frozen_string_literal: true

class AddImageToAppConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configs, :image, :string
  end
end
