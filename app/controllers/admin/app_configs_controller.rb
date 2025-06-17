# frozen_string_literal: true

module Admin
  class AppConfigsController < AdminController
    def index; end

    def edit; end

    def update
      authorize AppConfig

      if @app_config.update(app_configs_params)
        redirect_to edit_admin_app_config_path(@app_config.id)
      else
        render :edit
      end
    end

    private

    def app_configs_params
      params.require(:app_config).permit(
        :show_theme, :show_institutions,
        :main_title, :image,
        :intro_title, :intro_text
      )
    end
  end
end
