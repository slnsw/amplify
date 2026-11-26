# frozen_string_literal: true

require 'rails_helper'

# /admin/analytics embeds the institution's Looker Studio report
# (Admin::AnalyticsController#index). It needs a staff member with an
# institution and LOOKER_STUDIO_IFRAME_URL in the environment; the URL is pointed
# at the app's own health endpoint so the frame loads instead of failing on a
# host this environment cannot reach. Rendering without JavaScript errors is
# enforced by spec/support/features/javascript_errors.rb.
RSpec.feature 'Admin analytics' do
  let(:world) { build_content_world }
  let(:analytics) { AdminAnalyticsPage.new }

  describe 'as an admin with an institution', :js do
    around do |example|
      looker_url = ENV.fetch('LOOKER_STUDIO_IFRAME_URL', nil)
      example.run
    ensure
      ENV['LOOKER_STUDIO_IFRAME_URL'] = looker_url
    end

    before do
      world
      sign_in_as(:admin).update(institution: world.institution)
      ENV['LOOKER_STUDIO_IFRAME_URL'] = "#{Capybara.current_session.server.base_url}/health"
    end

    scenario 'frames the report of the signed-in institution' do
      analytics.visit_analytics

      expect(analytics.iframe_src).to include("guid=#{world.institution.guid}")
    end
  end
end
