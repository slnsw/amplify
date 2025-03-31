class AddResolvedToFlags < ActiveRecord::Migration[7.0]
  def change
    add_column :flags, :is_resolved, :integer, :null => false, :default => 0
  end
end
