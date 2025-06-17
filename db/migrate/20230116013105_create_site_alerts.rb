# frozen_string_literal: true

class CreateSiteAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :site_alerts do |t|
      t.string :machine_name, null: false
      t.string :level, null: false, default: 'status'
      t.text :message
      t.integer :user_id, null: false, default: 0
      t.boolean :published, default: false
      t.boolean :admin_access, default: false
      t.boolean :scheduled, default: false
      t.timestamp :publish_at
      t.timestamp :unpublish_at

      t.timestamps
    end
    add_index :site_alerts, :machine_name, unique: true
  end
end
