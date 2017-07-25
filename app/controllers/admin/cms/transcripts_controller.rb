class Admin::Cms::TranscriptsController < Admin::ApplicationController
  before_action :set_transcript, only: [:edit, :update]

  def new
    @transcript = Transcript.new(
      collection_id: Collection.find_by(uid: params[:collection_id]).id
    )
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

  def speaker_search
    speakers = Speaker.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%")
      .map  do |s|
        { id: s.id, label: s.name, value: s.name }
      end
    render json: speakers
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
      :url,
      :audio,
      :script,
      :image,
      :image_caption,
      :image_catalogue_url,
      :notes,
      :vendor_id,
      :collection_id,
      :speakers,
    ).merge(
      project_uid: ENV['PROJECT_ID']
    )
  end
end
