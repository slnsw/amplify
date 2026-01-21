class AddIntegerEnumColumns < ActiveRecord::Migration[8.0]
  def change
    # Add new integer columns (temporarily suffixed with _int)
    # Also replicated the default value and null constraints from the existing
    # string columns
    add_column :transcripts, :process_status_int, :integer
    add_column :site_alerts, :level_int, :integer, default: 0, null: false
    add_column :user_roles, :transcribing_role_int, :integer, default: 0

    add_index :transcripts, :process_status_int
    add_index :site_alerts, :level_int
    add_index :user_roles, :transcribing_role_int
  end
end
