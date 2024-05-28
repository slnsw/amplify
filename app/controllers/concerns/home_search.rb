module HomeSearch
  extend ActiveSupport::Concern

  private

  def sort_params
    params.permit(
      :sort_by, :search,
      :institution,
      :page,
      :per_page,
      themes: [],
      collections: []
    ).reject { |_, v| v.blank? }
  end

  def build_params
    sort_params.reject do |_key, value|
      return true if value.blank?

      if value.is_a?(Array)
        value.first.blank? || value.first == '0'
      end
    end
  end

  def load_institutions
    @institutions = if sort_params[:collections].blank?
                      Institution.published.joins(:collections).order(name: :asc).uniq
                    else
                      Institution.published.order(name: :asc).joins(:collections).
                        where("collections.title in (?)", sort_params[:collections])
                    end
  end

  def load_collections
    collection = Collection.published.with_published_institution.order(title: :asc)

    @collection = if sort_params[:institution].blank?
                    collection
                  else
                    collection.joins(:institution).
                      where("institutions.slug in (?)", sort_params[:institution]).
                      where("institutions.hidden = false")
                  end
  end
end
