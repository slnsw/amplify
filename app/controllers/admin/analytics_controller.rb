class Admin::AnalyticsController < AdminController
  before_action :authenticate_staff!

  def index
    raise ActionController::RoutingError.new('Not Found') unless current_user.institution.present?

    @institution = current_user.institution
    uri = URI(ENV['LOOKER_STUDIO_IFRAME_URL'])
    uri.query = URI.encode_www_form({ guid: @institution.guid, domain: ENV['DOMAIN'] })
    @analytics_url = uri.to_s
  end
end
