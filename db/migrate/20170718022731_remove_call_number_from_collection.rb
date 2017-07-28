class RemoveCallNumberFromCollection < ActiveRecord::Migration
  def change
    remove_column :collections, :call_number, :string
  end
end
