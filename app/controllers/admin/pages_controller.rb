class Admin::PagesController < AdminController
  include Authentication

  before_action :authenticate_admin!
  before_action :set_page, only: [:edit, :update, :destroy, :show]
  before_action -> { authorize Page }

  def index
    @pages = policy_scope(Page).order(page_type: :asc)
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)

    if @page.save
      redirect_to admin_pages_path
    else
      render :new
    end
  end

  def edit; end

  def show
    @page = @page.decorate
  end

  def update
    if @page.update(page_params)
      redirect_to admin_pages_path
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_path
  end

  def upload
    @upload = CmsImageUpload.new(image: page_params[:image])
    @upload.save
    render json: { url: @upload.image.url, upload_id: @upload.id }
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:content, :page_type,
                                 :image, :published, :admin_access)
  end
end
