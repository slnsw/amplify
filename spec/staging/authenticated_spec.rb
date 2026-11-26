# frozen_string_literal: true

require_relative 'staging_helper'

# The signed-in journeys, which need a real account on the deployment:
# STAGING_EMAIL and STAGING_PASSWORD. Without both, every example here skips — a
# remote browser cannot be authenticated with `sign_in_as`, which signs in the next
# request this process serves, so the real form is submitted instead.
#
# The read-only guard allows exactly one write: the POST to /users/sign_in that
# establishes the session. Everything after it reaches a known, read-only page by
# its path or by its one named link. These journeys never walk links
# (`expect_links_to_resolve`): a signed-in staff page links to GETs that are not
# read-only (`/users/sign_out` ends the session, `/admin/cms/transcripts/:id/sync`
# enqueues a paid Azure job), and the guard fails the run on those only after
# they have been sent. Signing out is covered locally
# (spec/features/auth/sign_out_spec.rb) for the same reason. The CSV report is
# deliberately not downloaded — it is a GET, but the HTML report is the page
# being verified.
#
# STAGING_EMAIL must belong to a staff account: the admin examples assert that the
# admin portal renders for it.
RSpec.feature 'Signed-in staging journeys', :js, :requires_credentials, :staging do
  before do
    SignInPage.new.visit_and_submit(email: ENV.fetch('STAGING_EMAIL'), password: ENV.fetch('STAGING_PASSWORD'))
    next if signed_in?

    skip("Signing in as #{ENV.fetch('STAGING_EMAIL')} did not reach a signed-in page " \
         "(#{page.current_url}); check STAGING_EMAIL and STAGING_PASSWORD")
  end

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

  scenario 'renders the contribution report as HTML', :aggregate_failures do
    AdminReportsPage.new.visit_index
    page.click_link('Users Activity')

    expect(page).to have_css('h3', text: 'User Contributions')
    expect(page).to have_css('.report-table')
  end

  scenario 'renders the CMS collection index' do
    expect(AdminCmsCollectionsPage.new.visit_index.titles).not_to be_empty
  end

  private

  # The header renders the account menu's sign-out link only for a signed-in
  # visitor (app/views/shared/_header.html.erb); it is hidden until the menu
  # opens, hence `visible: :all`. A rejected sign-in re-renders the form instead.
  def signed_in?
    page.has_link?('Sign out', visible: :all)
  end
end
