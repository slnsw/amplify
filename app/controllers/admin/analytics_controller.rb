class Admin::AnalyticsController < AdminController
  before_action :authenticate_staff!

  def index
    @institution = current_user.institution
    uri = URI(ENV['LOOKER_STUDIO_IFRAME_URL'])
    uri.query = "params[df235]=include%E2%80%800%E2%80%80PT%E2%80%80%2F#{@institution.guid}"
    @analytics_url = uri.to_s
  end
end
