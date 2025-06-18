class TranscriptLinesController < ApplicationController
  include LoggedInUserHelper
  skip_before_action :verify_authenticity_token, only: [:resolve]

  before_action :set_transcript_line, only: [:resolve]

  # POST /transcript_lines/1/resolve.json
  def resolve
    if logged_in_user.try(:staff?) && !@transcript_line.nil?
      @transcript_line.resolve
      Flag.resolve(@transcript_line.id)
    end

    head :no_content
  end

  private

  def set_transcript_line
    @transcript_line = TranscriptLine.find(params[:id])
  end
end
