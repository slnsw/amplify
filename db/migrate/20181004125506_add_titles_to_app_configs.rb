class AddTitlesToAppConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configs, :main_title, :string
  end
end
