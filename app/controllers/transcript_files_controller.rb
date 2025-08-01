class TranscriptFilesController < ApplicationController
  include ActionController::MimeResponds

  before_action :set_transcript, only: [:show, :update, :destroy]
  before_action :set_updated_after, only: [:index]

  # GET /transcripts.json?updated_after=yyyy-mm-dd&page=1
  def index
    @transcripts = Transcript.get_updated_after(@updated_after)
    @opt = transcript_file_params
  end

  # GET /transcript_files/the-uid.json?edits=1
  # GET /transcript_files/the-uid.text?timestamps=1&speakers=1
  # GET /transcript_files/the-uid.vtt?speakers=1
  def show
    @project = Project.getActive
    @transcript_lines = []
    @transcript_line_statuses = []
    @transcript_speakers = []
    @transcript_edits = []
    @opt = transcript_file_params

    if params[:format] == "json"
      @transcript_line_statuses = TranscriptLineStatus.allCached
      @transcript_speakers = TranscriptSpeaker.getByTranscriptId(@transcript.id)
      @transcript_edits = TranscriptEdit.getByTranscript(@transcript.id) if @opt[:edits]

    elsif @opt[:speakers]
      @transcript_lines = TranscriptLine.getByTranscriptWithSpeakers(@transcript.id)

    else
      @transcript_lines = @transcript.transcript_lines
    end
  end

  private

    def set_updated_after
      # default to all time
      @updated_after = 10.years.ago

      # look for parameters
      @updated_after = params[:updated_after].to_datetime unless params[:updated_after].blank?
    end

    def set_transcript
      @transcript = Transcript.find_by(uid: params[:id])
    end

    def transcript_file_params
      params.permit(:original_text, :edits, :timestamps, :speakers)
    end
end
