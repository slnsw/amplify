class AddPgSearchPgTrigramSupportFunctions < ActiveRecord::Migration[5.2]
  def self.up
    say_with_time("Adding support functions for pg_search :pg_trgm") do
      execute <<-'SQL'
        CREATE EXTENSION pg_trgm;
      SQL
    end
  end

  def self.down
    say_with_time("Dropping support functions for pg_search :pg_trgm") do
      execute <<-'SQL'
        DROP EXTENSION pg_trgm;
      SQL
    end
  end
end
