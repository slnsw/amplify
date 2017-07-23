class Admin::Cms::TranscriptsController < Admin::ApplicationController
  before_action :set_transcript, only: [:edit, :update]

  def new
    @transcript = Transcript.new(collection_id: get_collection.id)
  end

  def create
    @transcript = Transcript.new(transcript_params)

    if @transcript.save
      flash[:notice] = "The new transcript has been saved."
      redirect_to admin_cms_collection_path(@transcript.collection)
    else
      flash[:errors] = "The new transcript could not be saved."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transcript.update(transcript_params)
      flash[:notice] = "The transcript updates have been saved."
      redirect_to admin_cms_collection_path(@transcript.collection)
    else
      flash[:errors] = "The transcript updates could not be saved."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_transcript
    @transcript = Transcript.find_by(uid: params[:id])
  end

  def transcript_params
    params.require(:transcript).permit(
      :uid,
      :title,
      :description,
      :audio_catalogue_url,
      :audio,
      :script,
      :image,
      :image_caption,
      :image_catalogue_url,
      :notes,
      :vendor_id,
      :collection_id
    ).merge(
      project_uid: ENV['PROJECT_ID']
    )
  end

  def collection_id
    Collection.find_by(uid: params[:collection_uid]).id
  end

  def get_collection
    Collection.find_by(uid: params[:collection_id])
  end
end
