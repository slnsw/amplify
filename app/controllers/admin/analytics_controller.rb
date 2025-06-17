# frozen_string_literal: true

module Admin
  class AnalyticsController < AdminController
    before_action :authenticate_staff!

    def index
      raise ActionController::RoutingError, 'Not Found' if current_user.institution.blank?

      @institution = current_user.institution
      uri = URI(ENV['LOOKER_STUDIO_IFRAME_URL'])
      uri.query = URI.encode_www_form({ guid: @institution.guid, domain: ENV['DOMAIN'] })
      @analytics_url = uri.to_s
    end
  end
end
