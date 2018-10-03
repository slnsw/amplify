# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :configure_sign_up_params, only: [:create]
  # rubocop:enable Rails/LexicallyScopedActionFilter
  #

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
