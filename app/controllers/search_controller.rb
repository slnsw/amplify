class SearchController < ApplicationController
  before_action :load_collections
  before_action :load_institutions
  layout "application_v2"

  include HomeSearch

  def index
    @page_title = "Search"
    build_params[:page] ||= 1
    @build_params = build_params
    @transcripts = TranscriptSearch.new(build_params).transcripts
    @themes = Theme.all.order(name: :asc)
    @form_url = search_index_path
  end
end
