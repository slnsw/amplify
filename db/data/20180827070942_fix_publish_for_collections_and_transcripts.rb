# frozen_string_literal: true

class FixPublishForCollectionsAndTranscripts < SeedMigration::Migration
  def up
    # updating `publish` column for both collections and transcripts tables
    [Collection, Transcript].each do |klass|
      klass.published.update_all(publish: true)
      klass.unpublished.update_all(publish: false)
    end
  end

  def down
    [Collection, Transcript].each do |klass|
      klass.unscoped.update_all(publish: false)
    end
  end
end
