# frozen_string_literal: true

class AdminController < ApplicationController
  include Pundit
  layout 'admin'

  def authenticate_staff!
    redirect_to root_url unless current_user&.staff?
  end
end
