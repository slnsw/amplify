class CreateProject < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :uid, :null => false, :default => ""
      t.jsonb :data, :null => false, :default => '{}'
      t.boolean :active, :null => false, :default => false

      t.timestamps null: false
    end

    add_index :projects, :uid, :unique => true
  end
end
