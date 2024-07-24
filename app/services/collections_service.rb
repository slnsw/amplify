class CollectionsService
  def self.list
    Collection.with_published_institution
  end

  def self.by_institution(institution_slug)
    institution_slug =  if institution_slug.present? 
                          institution_slug
                        else
                          Institution.state_library_nsw.try(:slug)
                        end
    Collection.
      published.
      with_published_institution.
      order(title: :asc).
      joins(:institution).
      where("institutions.slug in (?)", institution_slug)
  end
end
