# frozen_string_literal: true

require_relative 'staging_helper'

# The signed-in journeys, which need a real account on the deployment. A remote
# browser cannot be authenticated with `sign_in_as`, which signs in the next request
# this process serves, so the real form is submitted instead.
#
# Two credential sets, because the pages grant different things:
#
# * STAGING_EMAIL / STAGING_PASSWORD — a staff account. Covers the dashboard and
#   `/admin/summary` (`Admin::SummaryController` declares `authenticate_staff!`).
# * STAGING_ADMIN_EMAIL / STAGING_ADMIN_PASSWORD — an admin. `/admin/reports`
#   declares `before_action :authenticate_admin!`, and `/admin/cms` authorises
#   `Collection`, whose policy allows only an admin or a content editor, so an
#   admin covers both.
#
# Without the relevant pair its journeys skip, so an ordinary staff account is
# still enough for the rest of the run. Give the admin account to the runner for
# these page loads only: that is all they do, and the read-only guard fails the run
# on anything else.
#
# The guard allows exactly one write: the POST to /users/sign_in that establishes
# the session. Everything after it reaches a known, read-only page by its path or by
# its one named link. These journeys never walk links (`expect_links_to_resolve`): a
# signed-in staff page links to GETs that are not read-only (`/users/sign_out` ends
# the session, `/admin/cms/transcripts/:id/sync` enqueues a paid Azure job), and the
# guard fails the run on those only after they have been sent. Signing out is
# covered locally (spec/features/auth/sign_out_spec.rb) for the same reason. The CSV
# report is deliberately not downloaded — it is a GET, but the HTML report is the
# page being verified.
RSpec.feature 'Signed-in staging journeys', :js, :staging do
  describe 'as a staff account', :requires_credentials do
    before { sign_in!(Staging::Target.email, Staging::Target.password) }

    scenario 'shows the signed-in visitor their dashboard', :aggregate_failures do
      dashboard = DashboardPage.new.visit_path

      expect(navigation_status).to be_between(200, 399)
      expect(dashboard.heading).to eq(DashboardPage::HEADING)
    end

    scenario 'renders the admin summary', :aggregate_failures do
      page.visit('/admin/summary')

      expect(navigation_status).to be_between(200, 399)
      expect(page).to have_css('h3', text: 'Collection transcription progress')
    end
  end

  describe 'as an admin account', :requires_admin_credentials do
    before { sign_in!(Staging::Target.admin_email, Staging::Target.admin_password) }

    scenario 'renders the contribution report as HTML', :aggregate_failures do
      AdminReportsPage.new.visit_index
      page.click_link('Users Activity')

      expect(page).to have_css('h3', text: 'User Contributions')
      expect(page).to have_css('.report-table')
    end

    scenario 'renders the CMS collection index' do
      expect(AdminCmsCollectionsPage.new.visit_index.titles).not_to be_empty
    end
  end

  private

  def sign_in!(email, password)
    SignInPage.new.visit_and_submit(email: email, password: password)
    return if signed_in?

    skip("Signing in as #{email} did not reach a signed-in page (#{page.current_url}); " \
         'check the staging credentials')
  end

  # The header renders the account menu's sign-out link only for a signed-in
  # visitor (app/views/shared/_header.html.erb); it is hidden until the menu
  # opens, hence `visible: :all`. A rejected sign-in re-renders the form instead.
  def signed_in?
    page.has_link?('Sign out', visible: :all)
  end
end
