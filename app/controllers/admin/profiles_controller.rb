class Admin::ProfilesController < ApplicationController
  include Pundit
  layout "admin"

  def index
    @user_role = current_user.user_role
  end

  def update
    update_transcribing_role if params.dig(:user_role, :commit) == "update_transcribing_role"

    redirect_to admin_profiles_path
  end

  private

  def update_transcribing_role
    return unless current_user.admin?

    transcribing_role = params.dig(:user_role, :transcribing_role)
    flash[:notice] = "Admin's transcribing role has been updated to #{transcribing_role}."
    current_user.user_role.update(transcribing_role: params.dig(:user_role, :transcribing_role))
  end
end
