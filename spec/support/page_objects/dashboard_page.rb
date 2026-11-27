# frozen_string_literal: true

# Selectors and navigation for the signed-in visitor's contribution dashboard
# (`/dashboard`, app/views/dashboard/index.html.erb). It deliberately has no
# assertions and no Rails/factory/DB dependency, so the remote staging layer
# (spec/staging) can drive the same object against a real host.
class DashboardPage
  HEADING = 'Your Recent Activity'
  HEADING_SELECTOR = '.search_results .cms h3'
  # One row per transcript the visitor edited; the title link sits under the
  # thumbnail link inside the image column.
  TRANSCRIPT_TITLES = '.flex-container__img_div div a'
  EDITS = '.transcript-edit'
  # `edited_info` (app/helpers/dashboard_helper.rb) renders a bare paragraph;
  # the empty state is the `.highlight` paragraph rendered instead of the rows.
  SUMMARY = '.search_results .cms p:not(.highlight)'
  EMPTY_STATE = '.search_results .cms p.highlight'

  def visit_path
    page.visit('/dashboard')
    self
  end

  def heading = page.find(HEADING_SELECTOR).text

  def transcript_titles = page.all(TRANSCRIPT_TITLES).map(&:text)

  def edits = page.all(EDITS).map(&:text)

  def summary = page.find(SUMMARY).text

  def empty_state = page.find(EMPTY_STATE).text

  private

  def page
    Capybara.current_session
  end
end
