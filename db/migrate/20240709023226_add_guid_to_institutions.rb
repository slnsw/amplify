class AddGuidToInstitutions < ActiveRecord::Migration[7.0]
  def change
    add_column :institutions, :guid, :string

    Institution.where(guid: nil).find_each do |institution|
      institution.save
    end
  end
end
