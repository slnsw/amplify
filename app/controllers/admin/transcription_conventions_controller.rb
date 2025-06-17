# frozen_string_literal: true

module Admin
  class TranscriptionConventionsController < AdminController
    before_action :set_institution
    before_action :set_transcription_convention, only: %i[edit update destroy]

    def index
      @transcription_conventions = @institution.transcription_conventions
    end

    def new
      @transcription_convention = @institution.transcription_conventions.build
    end

    def edit; end

    def create
      @transcription_convention = @institution.transcription_conventions.build(transcription_convention_params)

      if @transcription_convention.save
        redirect_to admin_institution_transcription_conventions_path(@institution)
      else
        render :new
      end
    end

    def update
      if @transcription_convention.update(transcription_convention_params)
        redirect_to admin_institution_transcription_conventions_path(@institution)
      else
        render :edit
      end
    end

    def destroy
      @transcription_convention.destroy
      redirect_to admin_institution_transcription_conventions_path(@institution)
    end

    private

    def set_transcription_convention
      @transcription_convention = @institution.transcription_conventions.find_by(id: params[:id])
    end

    def set_institution
      @institution = Institution.friendly.find(params[:institution_id])
    end

    def transcription_convention_params
      params.require(:transcription_convention).permit(:convention_key, :convention_text, :example)
    end
  end
end
