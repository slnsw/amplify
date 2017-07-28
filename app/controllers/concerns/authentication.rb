module Authentication
  extend ActiveSupport::Concern

  def authenticate_admin!
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
    unless is_moderator?
      authentication_failed
      return
    end
  end

  def authentication_failed
    respond_to do |format|
      format.html {
        redirect_to root_url(show_alert: 'You must log in as admin to access this section')
      }
      format.json {
        render json: {
          error: 1,
          message: 'You must log in as admin to access this section'
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
end
