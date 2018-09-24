class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:index, :transcripts]
  before_action :load_collection, except: [:index]
  before_action :load_institutions
  layout "application_v2"

  include Searchable

  def index
    @sort_list = SortList.list
    @themes = Theme.all
  end

  def transcripts
    @selected_collection_id = sort_params[:collection_id].to_i
    @selected_institution_id = select_institution_id
    @transcripts = TranscriptService.search(sort_params)
  end
end
