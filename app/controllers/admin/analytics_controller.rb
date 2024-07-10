class Admin::AnalyticsController < AdminController
  before_action :authenticate_staff!

  def index
    raise ActionController::RoutingError.new('Not Found') unless current_user.institution.present?
    
    @institution = current_user.institution
    uri = URI(ENV['LOOKER_STUDIO_IFRAME_URL'])
    uri.query="params={'df235':'include%25EE%2580%25800%25EE%2580%2580PT%25EE%2580%2580%252F#{@institution.guid}}"
    @analytics_url = uri.to_s
  end
end
