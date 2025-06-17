# frozen_string_literal: true

class AddPgSearchDmetaphoneSupportFunctions < ActiveRecord::Migration[7.0]
  def self.up
    execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;'

    execute <<-'SQL'.squish
      CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
        SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
      $function$;
    SQL
  end

  def self.down
    execute 'DROP EXTENSION IF EXISTS fuzzystrmatch;'
    execute <<-'SQL'.squish
      DROP FUNCTION pg_search_dmetaphone(text);
    SQL
  end
end
