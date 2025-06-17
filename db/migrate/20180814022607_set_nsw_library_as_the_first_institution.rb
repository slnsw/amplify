# frozen_string_literal: true

class SetNswLibraryAsTheFirstInstitution < ActiveRecord::Migration[5.2]
  def change
    # move_out_of_migration
    # institution = Institution.find_or_initialize_by(name: 'State Library of New South Wales')
    # institution.save

    # update existing collections
    # Collection.update_all(institution_id: institution.id)
  end
end
