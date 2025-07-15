class FinalizeIntegerEnumMigration < ActiveRecord::Migration[8.0]
  def up
    remove_column :transcripts, :process_status
    remove_column :site_alerts, :level
    remove_column :user_roles, :transcribing_role

    # Rename new integer columns to original names
    rename_column :transcripts, :process_status_int, :process_status
    rename_column :site_alerts, :level_int, :level
    rename_column :user_roles, :transcribing_role_int, :transcribing_role
  end

  def down
    rename_column :transcripts, :process_status, :process_status_int
    rename_column :site_alerts, :level, :level_int
    rename_column :user_roles, :transcribing_role, :transcribing_role_int

    add_column :transcripts, :process_status, :string
    add_column :site_alerts, :level, :string
    add_column :user_roles, :transcribing_role, :string

    execute <<-SQL
      UPDATE transcripts
      SET process_status = CASE
        WHEN process_status_int = 0 THEN 'started'
        WHEN process_status_int = 1 THEN 'completed'
        WHEN process_status_int = 2 THEN 'failed'
        ELSE NULL
      END
      WHERE process_status_int IS NOT NULL;
    SQL

    execute <<-SQL
      UPDATE site_alerts
      SET level = CASE
        WHEN level_int = 0 THEN 'status'
        WHEN level_int = 1 THEN 'warning'
        WHEN level_int = 2 THEN 'error'
        ELSE NULL
      END
      WHERE level_int IS NOT NULL;
    SQL

    execute <<-SQL
      UPDATE user_roles
      SET transcribing_role = CASE
        WHEN transcribing_role_int = 0 THEN 'registered_user'
        WHEN transcribing_role_int = 1 THEN 'admin'
        ELSE NULL
      END
      WHERE transcribing_role_int IS NOT NULL;
    SQL
  end
end
