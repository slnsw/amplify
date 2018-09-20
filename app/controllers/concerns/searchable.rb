module Searchable
  extend ActiveSupport::Concern

  private

  def sort_params
    params.require(:data).permit(
      :collection_id, :sort_id, :text,
      :institution_id,
      :theme
    )
  end

  def select_institution_id
    # if the institution_id is != 0 then get it
    # if the collection id is != 0 then get that collections institution id
    # if the collection id == 0, then make the institution id also as 0
    if sort_params[:institution_id].to_i > 0
      sort_params[:institution_id].to_i
    else
      Collection.where(id: sort_params[:collection_id]).
        first&.institution_id.to_i
    end
  end

  def load_institutions
    new_institution = Institution.new(id: 0, name: "All Institutions")
    collection_id = params[:data] && sort_params.fetch(:collection_id)
    @institutions = if collection_id.to_i == 0
                      Institution.all
                    else
                      Institution.joins(:collections).
                        where("collections.id = ?", collection_id)
                    end.to_a.unshift(new_institution)
  end

  def load_collection
    new_collection = Collection.new(id: 0, title: "All Collections")
    institution_id = sort_params[:institution_id].to_i
    collection = Collection.published
    @collection = if institution_id > 0
                    collection.where(institution_id: institution_id)
                  else
                    collection
                  end.to_a.unshift(new_collection)
  end
end
