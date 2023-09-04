# public institutions controller
class InstitutionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:index]
  before_action :load_institution
  before_action :load_collections
  before_action :load_institutions
  before_action :filter_requests, only: [:index]
  layout "application_v2"

  include HomeSearch

  def index
    @transcripts = TranscriptService.search(@build_params)
    @themes = Theme.all.order(name: :asc)
    @sort_list = SortList.list
    @form_url = institution_path(path: params[:path])
    @disabled = true

    load_institution_footer
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def load_institution
    @institution = Institution.friendly.find(params_list[:institution_id])
    @build_params = build_params.to_h
  end

  def load_institutions
    @institutions = [@institution]
    @build_params[:institution] = @institution.slug
  end

  def load_collections
    collection = Collection.published.order(title: :asc)
    if params_list[:collection_id]
      @collection = [collection.find_by(uid: params_list[:collection_id])]
      @build_params[:collections] = [@collection.first.title]
    else
      @collection = collection.
        joins(:institution).
        where("institutions.slug in (?)", params_list[:institution_id])
    end
  end

  def load_institution_footer
    @global_content[:footer_links] = @institution.institution_links
  end

  def render_404
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: "public", status: :not_found }
      format.xml  { head :not_found  }
      format.any  { head :not_found  }
    end
  end

  def params_list
    list = params[:path].to_s.split("/")
    {
      institution_id: list.shift,
      collection_id: list.shift
    }
  end

  def filter_requests
    return head :not_found if (params[:format] && params[:format] != "html")
  end
end
