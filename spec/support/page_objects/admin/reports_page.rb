# frozen_string_literal: true

require 'csv'

# Selectors and navigation for admin reporting (app/views/admin/reports/). The
# user-contribution report renders as a table at /admin/reports/users and as CSV
# at /admin/reports/users.csv (Reports::UserContributions).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminReportsPage
  include ListTexts

  INDEX_PATH = '/admin/reports'
  USERS_PATH = '/admin/reports/users'
  USERS_CSV_PATH = '/admin/reports/users.csv'
  ROWS = '.report-table tbody tr'
  NAME_CELL = 'td:nth-child(1)'
  LINES_CELL = 'td:nth-child(2)'
  EDITS_CELL = 'td:nth-child(3)'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def visit_users
    page.visit(USERS_PATH)
    page.all(ROWS, minimum: 1)
    self
  end

  def contributor_names = texts_for("#{ROWS} #{NAME_CELL}")

  def lines_for(name) = cell(name, LINES_CELL)

  def edits_for(name) = cell(name, EDITS_CELL)

  def users_csv
    page.visit(USERS_CSV_PATH)
    CSV.parse(page.body, headers: true)
  end

  private

  def cell(name, selector) = page.find(ROWS, text: name).find(selector).text

  def page
    Capybara.current_session
  end
end
