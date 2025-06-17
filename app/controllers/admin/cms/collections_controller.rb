# frozen_string_literal: true

module Admin
  module Cms
    class CollectionsController < AdminController
      before_action :authenticate_staff!

      before_action :set_collection, only: %i[show edit update destroy]
      before_action :load_institutions, only: %i[new create edit update]
      before_action :load_themes, only: %i[new create edit update]

      def show; end

      def new
        @collection = Collection.new
      end

      def create
        @collection = Collection.new(resource_params)
        @collection.theme_list.add(theme_list)

        if @collection.save
          flash[:notice] = 'The new collection has been saved.'
          redirect_to admin_cms_path
        else
          flash[:errors] = 'The new collection could not be saved.'
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        @collection.theme_list = theme_list
        remove_image
        if @collection.update(resource_params)
          flash[:notice] = 'The collection updates have been saved.'
          redirect_to admin_cms_path
        else
          flash[:errors] = 'The collection updates could not be saved.'
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        # only admins
        authorize @collection

        @collection.destroy
        flash[:notice] = 'Collection has been deleted'
        redirect_to admin_cms_path
      end

      private

      def load_institutions
        @institutions = InstitutionPolicy::Scope.new(current_user,
                                                     Institution).resolve
      end

      def set_collection
        @collection = Collection.find_by uid: params[:id]
      end

      def theme_list
        params[:collection][:theme_ids].reject(&:blank?)
      end

      def load_themes
        @themes = Theme.all.order(name: :asc)
      end

      def resource_params
        params.require(:collection).permit(
          :uid, :title,
          :library_catalogue_title, :description,
          :url, :image,
          :vendor_id, :institution_id,
          :publish, :collection_url_title,
          :min_lines_for_consensus
        ).merge(
          project_uid: ENV['PROJECT_ID']
        )
      end

      def remove_image
        @collection.remove_image! if remove_image_params.present?
      end

      def remove_image_params
        params.require(:collection).permit(:remove_image)
      end
    end
  end
end
