class AddingIntroFieldsToAppConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configs, :intro_title, :string
    add_column :app_configs, :intro_text, :text
  end
end
