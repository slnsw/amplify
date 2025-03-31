class CreateTranscriptStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :transcript_statuses do |t|
      t.string :name, :null => false, :default => ""
      t.integer :progress, :null => false, :default => 0
      t.string :description

      t.timestamps null: false
    end

    add_index :transcript_statuses, :name, :unique => true
  end
end
