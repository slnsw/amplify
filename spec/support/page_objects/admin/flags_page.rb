# frozen_string_literal: true

# Selectors and navigation for the moderator queue an admin moderates from the
# dashboard: /admin renders `admin/stats/_flags_table`, one row per unresolved
# error flag (app/views/admin/stats/index.html.erb).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminFlagsPage
  DASHBOARD_PATH = '/admin'
  FLAGS_HEADING = 'Unresolved Flags'
  ROWS = 'table tbody tr'
  # Each row renders institution, flag type, note, item and line.
  TYPE_CELL = 'td:nth-child(2)'

  def visit_dashboard
    page.visit(DASHBOARD_PATH)
    # Without its heading the table would simply be absent, which would make an
    # empty queue pass for the wrong reason.
    page.find('h3', text: FLAGS_HEADING)
    self
  end

  # The dashboard renders the table server-side, so the rows are final once the
  # page has loaded.
  def pending_flags = page.all(ROWS).map(&:text)

  def flag_types = page.all("#{ROWS} #{TYPE_CELL}").map(&:text)

  private

  def page
    Capybara.current_session
  end
end
