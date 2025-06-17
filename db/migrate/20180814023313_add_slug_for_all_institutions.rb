# frozen_string_literal: true

class AddSlugForAllInstitutions < ActiveRecord::Migration[5.2]
  def change
    Institution.find_each(&:save)
  end
end
