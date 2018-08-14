class UpdateSlugOnInstitutions < ActiveRecord::Migration[5.2]
  def change
    # update the existing institutions to have the slug
    # Institution.find_each(&:save)
  end
end
