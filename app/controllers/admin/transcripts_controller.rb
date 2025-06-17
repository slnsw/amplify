# frozen_string_literal: true

module Admin
  class TranscriptsController < ApplicationController
    include ActionController::MimeResponds

    before_action :authenticate_admin!

    # GET /admin/transcripts
    # GET /admin/transcripts.json
    def index
      respond_to do |format|
        format.html do
          render file: environment_admin_file
        end
        format.json do
          @transcripts = []
        end
      end
    end
  end
end
