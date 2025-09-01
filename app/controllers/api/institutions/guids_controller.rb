class Api::Institutions::GuidsController < ActionController::Base
  before_action :authenticate_request

  def index
    data = Institution.all.select(:slug, :guid).map { |i| { UID: i.slug, GUID: i.guid } }

    render json: data
  end

  private

  def authenticate_request
    token = extract_bearer_token
    if token != ENV['LOOKER_STUDIO_EXTERNAL_SECRET']
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def extract_bearer_token
    auth_header = request.headers['Authorization']
    if auth_header && auth_header.start_with?('Bearer ')
      auth_header.split(' ').last
    else
      nil
    end
  end
end
