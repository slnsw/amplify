class TokensController < ApplicationController
  def regenerate
    refresh_token = params[:refresh_token]
    begin
      @new_token = TokenService.regenerate_token(refresh_token)
    rescue TokenService::InvalidTokenError => e
      @error_message = "An error occurred: #{e.message}"
    end

    respond_to do |format|
      format.js
    end
  end
end