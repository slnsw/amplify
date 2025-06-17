# frozen_string_literal: true

class CollectionsService
  def self.list
    Collection.with_published_institution
  end

  def self.by_institution(institution_slug)
    institution_slug =  institution_slug.presence || Institution.state_library_nsw.try(:slug)
    Collection
      .published
      .with_published_institution
      .order(title: :asc)
      .joins(:institution)
      .where(institutions: { slug: institution_slug })
  end
end
