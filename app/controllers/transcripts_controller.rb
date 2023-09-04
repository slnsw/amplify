class TranscriptsController < ApplicationController
  layout "application_v2"

  skip_before_action :verify_authenticity_token, only: [:index, :search, :show]

  include ActionController::MimeResponds
  include IndexTemplate

  before_action :set_transcript, only: [:update, :destroy]
  before_action :set_transcript_for_show, only: [:show]
  before_action :load_institution_footer, only: [:show]
  before_action :load_institution, only: [:show]

  # GET /transcripts.json
  def index
    project = Project.getActive
    @project_settings = project[:data]
    @transcripts = Transcript.getForHomepage(params[:page], order: "id")
  end

  # GET /search?sort_by=completeness&order=desc&collection_id=1&q=amy&page=1
  # GET /search.json?sort_by=completeness&order=desc&collection_id=1&q=amy&page=1
  def search
    respond_to do |format|
      format.html
      format.json do
        project = Project.getActive
        @project_settings = project[:data]
        @transcripts = Transcript.search(search_params)
      end
    end
  end

  # GET /transcripts/the-uid
  # GET /transcripts/the-uid.json
  def show
    if @institution && @collection && (!params[:institution] || !params[:collection]) && !params[:format]
      transcript_params = [@institution&.slug, @collection.uid, params[:id]]
      transcript_params.push({t: params[:t]}) if params[:t]
      transcript_params.push({preview: true}) if params[:preview]

      return redirect_to institution_transcript_path(*transcript_params)
    end

    respond_to do |format|
      format.html do
        @body_class = "body--transcript-edit"
        @page_subtitle = @transcript.title
        @secondary_navigation = "secondary_navigation"
      end
      format.json do
        @user_role = nil
        @user_edits = []
        @transcript_line_statuses = TranscriptLineStatus.allCached
        @transcript_speakers = TranscriptSpeaker.getByTranscriptId(@transcript.id)
        @flag_types = FlagType.byCategory("error")
        @user_flags = []
        @transcription_conventions = @transcript.transcription_conventions
        @instructions = Page.find_by(page_type: "instructions").public_page.decorate

        user = logged_in_user

        if user
          @user_edits = TranscriptEdit.getByTranscriptUser(@transcript.id, user.id)
          @user_role = user.user_role
          @user_flags = Flag.getByTranscriptUser(@transcript.id, user.id)
        else
          @user_edits = TranscriptEdit.getByTranscriptSession(@transcript.id, session.id.to_s)
          @user_flags = Flag.getByTranscriptSession(@transcript.id, session.id.to_s)
        end
      end
    end
  end

  # POST /transcripts.json
  def create
    @transcript = Transcript.new(transcript_params)

    if @transcript.save
      render json: @transcript, status: :created, location: @transcript
    else
      render json: @transcript.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transcripts/the-uid.json
  def update
    if @transcript.update(transcript_params)
      head :no_content
    else
      render json: @transcript.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transcripts/the-uid.json
  def destroy
    @transcript.destroy

    head :no_content
  end

  private

  def set_transcript
    @transcript = TranscriptService.find_by_uid(params[:id])
  end

  def set_transcript_for_show
    @transcript = TranscriptService.find_by_uid_for_admin(params[:id], logged_in_user)
  end

  def transcript_params
    params.require(:transcript).permit(:title, :description, :url, :audio_url, :image_url, :collection_id, :notes, :transcript_status_id)
  end

  def search_params
    params.permit(:sort_by, :order, :collection_id, :q, :page, :deep)
  end

  # since we we using a combination of devise + rails and
  # API authenticatoin (with backbone in transcript edits page)
  # we need to check warden session here
  def logged_in_user
    warden.user
  end

  def collection
    @collection ||= @transcript&.collection
  end

  def load_institution
    @institution ||= collection&.institution
  end

  def load_institution_footer
    links = @transcript&.collection&.institution&.institution_links
    @global_content[:footer_links] = links if links&.any?
  end
end
