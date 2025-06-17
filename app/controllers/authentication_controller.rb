# frozen_string_literal: true

class AuthenticationController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authenticate
    @user = current_user || User.new
  end
end
