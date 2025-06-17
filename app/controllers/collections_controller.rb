# frozen_string_literal: true

class CollectionsController < ApplicationController
  include ActionController::MimeResponds
  include IndexTemplate

  layout 'application_v2', only: [:index]

  before_action :set_collection, only: %i[show update destroy]

  # GET /collections.json
  def index
    @page_title = 'Collections'
    @institutions = Institution.published.order(:name)
    @page = Page.find_by(page_type: 'collections')&.public_page&.decorate
    @build_params = params
  end

  def list
    @collections = CollectionsService.by_institution(params[:institution_slug])
  end

  # GET /collections/the-uid.json
  def show; end

  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)

    if @collection.save
      render json: @collection, status: :created, location: @collection
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/the-uid.json
  def update
    if @collection.update(collection_params)
      head :no_content
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end

  # DELETE /collections//the-uid.json
  def destroy
    @collection.destroy

    head :no_content
  end

  private

  def set_collection
    @collection = Collection.find_by uid: params[:id]
  end

  def collection_params
    params.require(:collection).permit(:uid,
                                       :title,
                                       :description,
                                       :url,
                                       :image_url,
                                       :vendor_id,
                                       :vendor_identifier)
  end
end
