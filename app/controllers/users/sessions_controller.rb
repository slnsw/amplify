# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :configure_sign_in_params, only: [:create]
    invisible_captcha only: [:create]

    # GET /resource/sign_in

    # POST /resource/sign_in

    protected

    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    end
  end
end
