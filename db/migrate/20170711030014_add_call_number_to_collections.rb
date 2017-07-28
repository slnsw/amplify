class AddCallNumberToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :call_number, :string, null: false, default: ""
  end
end
