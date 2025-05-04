module LoggedInUserHelper
  def share_token
    @share_token ||= TokenService.encode(logged_in_user.id)
  end

  def refresh_token
    @refresh_token ||= TokenService.encode(logged_in_user.id, 30.days.from_now)
  end

  # since we we using a combination of devise + rails and
  # API authenticatoin (with backbone in transcript edits page)
  # we need to check warden session here
  def logged_in_user
    @logged_in_user ||= if params[:share_token].present?
                          decoded_token = TokenService.decode(params[:share_token])
                          User.find(decoded_token[:user_id])
                        else
                          warden.user
                        end
  end
end
