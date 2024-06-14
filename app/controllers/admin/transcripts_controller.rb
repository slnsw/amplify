class Admin::TranscriptsController < ApplicationController
  include ActionController::MimeResponds
  include IndexTemplate

  before_action :authenticate_admin!

  # GET /admin/transcripts
  # GET /admin/transcripts.json
  def index
    respond_to do |format|
      format.html {
        render :file => environment_admin_file
      }
      format.json {
        @transcripts = []
      }
    end
  end

end
