# frozen_string_literal: true

module Admin
  class ThemesController < AdminController
    before_action :set_theme, only: %i[edit update destroy]

    def index
      @themes = policy_scope(Theme).order('LOWER(name)')
    end

    def new
      authorize Theme

      @theme = Theme.new
    end

    def edit; end

    def create
      authorize Theme

      @theme = Theme.new(theme_params)

      if @theme.save
        redirect_to admin_themes_path
      else
        render :new
      end
    end

    def update
      if @theme.update(theme_params)
        redirect_to admin_themes_path
      else
        render :edit
      end
    end

    def destroy
      authorize Theme

      @theme.destroy
      redirect_to admin_themes_path
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = Theme.find(params[:id])
      authorize @theme
    end

    def theme_params
      params.require(:theme).permit(:name)
    end
  end
end
