# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:index]
  before_action :load_collections
  before_action :load_institutions
  layout 'application_v2'

  include HomeSearch

  def index
    @build_params = build_params
    @transcripts = TranscriptService.search(build_params)
    @themes = Theme.all.order(name: :asc)
    @sort_list = SortList.list
    @form_url = root_path
  end
end
