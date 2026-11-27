# frozen_string_literal: true

# Selectors and navigation for the embedded analytics dashboard
# (app/views/admin/analytics/index.html.erb), which frames the Looker Studio
# report for the signed-in staff member's institution.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminAnalyticsPage
  PATH = '/admin/analytics'
  IFRAME = 'iframe'

  def visit_analytics
    page.visit(PATH)
    self
  end

  def iframe_src = page.find(IFRAME)[:src]

  private

  def page
    Capybara.current_session
  end
end
