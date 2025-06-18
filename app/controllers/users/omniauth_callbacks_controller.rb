# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable

  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      remember_me @user
      sign_in @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to(new_user_registration_url, allow_other_host: true) && return
    end

    redirect_to redirect_url
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      remember_me @user
      sign_in @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to(new_user_registration_url, allow_other_host: true) && return
    end

    redirect_to redirect_url
  end

  private

  def redirect_url
    if params["state"]
      uid         = params["state"]
      transcript  = Transcript.find_by uid: uid
      return "/" unless transcript

      collection  = transcript.collection.uid
      institution = transcript.collection.institution.slug

      institution_transcript_path(institution: institution, collection: collection, id: transcript.uid)
    else
      "/"
    end
  end
end
