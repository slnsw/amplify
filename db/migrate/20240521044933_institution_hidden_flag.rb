class InstitutionHiddenFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :institutions, :hidden, :boolean, default: false
  end
end
