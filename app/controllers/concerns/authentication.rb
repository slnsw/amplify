module Authentication
  extend ActiveSupport::Concern

  def authenticate_admin!
    get_current_user
    unless is_admin?
      if is_moderator?
        redirect_to moderator_url
        return
      else
        authentication_failed
        return
      end
    end
  end

  def authenticate_moderator!
    get_current_user
    unless is_moderator?
      authentication_failed
      return
    end
  end

  def authentication_failed
    respond_to do |format|
      format.html {
        redirect_to root_url(show_alert: 'You must log in as admin to access this section.')
      }
      format.json {
        render json: {
          error: 1,
          message: 'You must log in as admin to access this section.'
        }
      }
    end
    return
  end

  def is_admin?
    user_signed_in? && current_user.isAdmin?
  end

  def is_moderator?
    user_signed_in? && current_user.isModerator?
  end

  def get_current_user
    return nil unless request.cookies.key?('authHeaders')
    auth_headers = JSON.parse(request.cookies['authHeaders'])

    expiration_datetime = DateTime.strptime(auth_headers["expiry"], "%s")
    current_user = User.find_by(uid: auth_headers["uid"])

    if current_user &&
       current_user.tokens.has_key?(auth_headers["client"]) &&
       expiration_datetime > DateTime.now

      @current_user = current_user
    end
    @current_user
  end
end
