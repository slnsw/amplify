# frozen_string_literal: true

class AddPgSearchPgTrigramSupportFunctions < ActiveRecord::Migration[5.2]
  def self.up
    say_with_time('Adding support functions for pg_search :pg_trgm') do
      execute <<-'SQL'.squish
        CREATE EXTENSION pg_trgm;
      SQL
    end
  end

  def self.down
    say_with_time('Dropping support functions for pg_search :pg_trgm') do
      execute <<-'SQL'.squish
        DROP EXTENSION pg_trgm;
      SQL
    end
  end
end
