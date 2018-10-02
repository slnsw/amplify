class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "application_v2"

  def index
    @transcript_edits = TranscriptEdit.getByUser(current_user.id).joins(:transcript)
  end
end
