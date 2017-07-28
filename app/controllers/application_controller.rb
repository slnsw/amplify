class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Authentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :exception

  # Allow us to use JBuilder
  include ActionController::ImplicitRender

  # Allow us to cache
  # include ActionController::Caching
  # self.perform_caching = true
  # self.cache_store = ActionController::Base.cache_store

  before_filter :touch_session

  # Ensure a session id is available for all!
  def touch_session
    session[:touched] = 1
  end
end
