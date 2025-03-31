class CreateFlags < ActiveRecord::Migration[7.0]
  def change
    create_table :flags do |t|
      t.integer :transcript_id, :null => false, :default => 0
      t.integer :transcript_line_id, :null => false, :default => 0
      t.integer :user_id, :null => false, :default => 0
      t.string :session_id, :null => false, :default => ""
      t.integer :flag_type_id, :null => false, :default => 0
      t.string :text, :null => false, :default => ""
      t.integer :is_deleted, :null => false, :default => 0

      t.timestamps null: false
    end

    add_index :flags, :transcript_line_id
    add_index :flags, :transcript_id
    add_index :flags, :user_id

    create_table :flag_types do |t|
      t.string :name, :null => false, :default => ""
      t.string :label, :null => false, :default => ""
      t.string :description, :null => false, :default => ""
      t.string :category, :null => false, :default => ""
    end
    add_index :flag_types, :name, :unique => true
    add_index :flag_types, :category

    add_column :transcript_lines, :flag_count, :integer, :null => false, :default => 0
  end
end
