class Admin::Cms::TranscriptsController < AdminController
  # Deals with publishing, unpublishing, and deleting multiple transcripts.
  include UpdateMultipleTranscriptsConcern

  before_action :set_transcript, only: [:edit, :update, :destroy, :reset_transcript, :sync]
  before_action :set_transcript_by_id, only: [:process_transcript]
  before_action :set_collection, only: [:update_multiple]

  def new
    @transcript = Transcript.new(collection_id: collection_id, transcript_type: :azure)
  end

  def create
    @transcript = Transcript.new(transcript_params.merge(vendor_id: Vendor.first&.id))

    if @transcript.save && @transcript.update(speakers: transcript_params[:speakers])
      flash[:notice] = "The new transcript has been saved."
      redirect_to admin_cms_collection_path(@transcript.collection)
    else
      flash[:errors] = "The new transcript could not be saved."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    remove_image
    if @transcript.update(transcript_params)
      flash[:notice] = "The transcript updates have been saved."
      redirect_to admin_cms_collection_path(@transcript.collection)
    else
      flash[:errors] = "The transcript updates could not be saved."
      render :edit, status: :unprocessable_entity
    end
  end

  def sync
    if @transcript.azure?
      Azure::SpeechToTextJob.perform_later @transcript.id
    end
    @transcript.reload
  end

  def destroy
    # only admins
    authorize @transcript
    @transcript.destroy
    flash[:notice] = "Transcript item has been deleted"
    redirect_to admin_cms_collection_path(@transcript.collection)
  end

  def speaker_search
    speakers = Speaker.
      where("LOWER(name) LIKE ?", "%#{params[:query].downcase}%").
      map do |s|
        { value: s.name, data: s.name }
      end
    render json: { suggestions: speakers }
  end

  def reset_transcript
    TranscriptService.new(@transcript).reset
    # this functionality is only for admins, error will be raised and
    # lodged in bugsnag in an event of an error
    flash[:notice] = "Transcript reset successful"
    redirect_to admin_cms_collection_path(@transcript.collection)
  end

  def process_transcript
    ingest_transcript
    @transcript.reload
    render json: {
      lines: @transcript.lines,
    }
  end

  def update_multiple
    if params[:transcript_ids]
      case params[:commit]
      when "publish"
        publish_trancripts(params[:transcript_ids])
      when "unpublish"
        unpublish_trancripts(params[:transcript_ids])
      when "delete"
        delete_trancripts(params[:transcript_ids])
      else
        flash.now[:notice] = "Unknown action"
      end
    else
      flash.now[:notice] = "Please select some transcripts"
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def set_transcript
    @transcript = Transcript.find_by(uid: params[:id])
  end

  def set_transcript_by_id
    @transcript = Transcript.find(params[:id])
  end

  # rubocop:disable Metrics/MethodLength
  def transcript_params
    params.require(:transcript).permit(
      :uid, :title,
      :description, :url,
      :audio, :script,
      :crop_x, :crop_y, :crop_w, :crop_h,
      :image, :image_caption,
      :image_catalogue_url,
      :notes, :collection_id, :speakers,
      :publish, :audio_item_url_title,
      :image_item_url_title,
      :transcript_type
    ).merge(
      project_uid: ENV["PROJECT_ID"],
    )
  end
  # rubocop:enable Metrics/MethodLength

  def collection_id
    Collection.find_by(uid: params[:collection_uid]).id
  end

  def ingest_transcript
    imp = VoiceBase::ImportSrtTranscripts.new(project_id: ENV["PROJECT_ID"])
    imp.process_single(@transcript.id)
  end

  def set_collection
    @collection = Collection.find_by(uid: params[:collection_uid])
  end

  def remove_image
    @transcript.remove_image! if remove_image_params.present?
  end

  def remove_image_params
    params.require(:transcript).permit(:remove_image)
  end
end
