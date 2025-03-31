class AddCallNumberToCollections < ActiveRecord::Migration[7.0]
  def change
    add_column :collections, :call_number, :string, null: false, default: ""
  end
end
