# This migration comes from acts_as_taggable_on_engine (originally 4)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingTaggableIndex < ActiveRecord::Migration[4.2]; end
else
  class AddMissingTaggableIndex < ActiveRecord::Migration[7.0]; end
end
AddMissingTaggableIndex.class_eval do
  def self.up
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
