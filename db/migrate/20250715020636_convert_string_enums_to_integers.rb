class ConvertStringEnumsToIntegers < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE transcripts
      SET process_status_int = CASE
        WHEN process_status = 'started' THEN 0
        WHEN process_status = 'completed' THEN 1
        WHEN process_status = 'failed' THEN 2
        ELSE NULL
      END
      WHERE process_status IS NOT NULL;
    SQL

    execute <<-SQL
      UPDATE site_alerts
      SET level_int = CASE
        WHEN level = 'status' THEN 0
        WHEN level = 'warning' THEN 1
        WHEN level = 'error' THEN 2
        ELSE NULL
      END
      WHERE level IS NOT NULL;
    SQL

    execute <<-SQL
      UPDATE user_roles
      SET transcribing_role_int = CASE
        WHEN transcribing_role = 'registered_user' THEN 0
        WHEN transcribing_role = 'admin' THEN 1
        ELSE NULL
      END
      WHERE transcribing_role IS NOT NULL;
    SQL
  end

  def down
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
