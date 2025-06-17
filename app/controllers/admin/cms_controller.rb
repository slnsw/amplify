# frozen_string_literal: true

module Admin
  class CmsController < AdminController
    def show
      authorize Collection

      @collection = policy_scope(Collection)
                    .includes(:institution)
                    .joins('INNER JOIN institutions ON collections.institution_id = institutions.id ')
                    .order('LOWER(institutions.name), LOWER(collections.title)')

      @collection = @collection.group_by(&:institution_id)
    end
  end
end
