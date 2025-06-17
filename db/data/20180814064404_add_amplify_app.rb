# frozen_string_literal: true

class AddAmplifyApp < SeedMigration::Migration
  def up
    AppConfig.send :create!, { app_name: 'State Library of New South Wales' }
  end

  def down
    AppConfig.delete_all
  end
end
