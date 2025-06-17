# frozen_string_literal: true

module Admin
  class InstitutionsController < AdminController
    before_action :set_institution, only: %i[edit update destroy]

    def index
      @institutions = policy_scope(Institution).order('LOWER(name)')
    end

    def new
      authorize Institution

      @institution = Institution.new
    end

    def edit; end

    def create
      authorize Institution

      @institution = Institution.new(institution_params)

      if @institution.save
        redirect_to admin_institutions_path
      else
        render :new
      end
    end

    def update
      authorize Institution

      save_institution_links
      remove_images

      if @institution.update(institution_params)
        redirect_to admin_institutions_path
      else
        render :edit
      end
    end

    def destroy
      authorize Institution

      DeleteInstitutionJob.perform_later(@institution.name, @institution.id, current_user.email)
      flash[:notice] = "Institution is being deleted in the background. You will receive an email when it's finished."
      redirect_to admin_institutions_path
    end

    private

    def save_institution_links
      InstitutionLink.where(institution: @institution).delete_all

      institution_links_params[:institution_links].to_a.each do |link|
        InstitutionLink.create(title: link[:title], url: link[:url], position: link[:position], institution: @institution)
      end
    end

    def remove_images
      @institution.remove_image! if remove_image_params.present?
      @institution.remove_hero_image! if remove_hero_image_params.present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_institution
      @institution = Institution.friendly.find(params[:id])
      authorize @institution
    end

    def institution_params
      params.require(:institution).permit(
        :name, :url, :image, :slug, :hero_image,
        :introductory_text, :hidden, :min_lines_for_consensus
      )
    end

    def institution_links_params
      params.require(:institution).permit(institution_links: %i[title url position])
    end

    def remove_image_params
      params.require(:institution).permit(:remove_image)
    end

    def remove_hero_image_params
      params.require(:institution).permit(:remove_hero_image)
    end
  end
end
