# frozen_string_literal: true

# Selectors and interactions for the admin dashboard's statistics
# (app/views/admin/stats/): the site-wide edit and registration counts, and the
# per-institution counts the institution select loads from
# /admin/stats/:id/institution (app/assets/javascripts/stats.js).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminStatsPage
  DASHBOARD_PATH = '/admin'
  # `_stats.html.erb` renders one card per StatService group, each holding a
  # `.sum` per labelled count.
  ITEM_EDITS_CARD = 'Item edits'
  SUM = '.sum'
  SUM_LABEL = '.sum-label'
  SUM_VALUE = '.sum-value'
  INSTITUTION_SELECT = 'institution_id'
  INSTITUTION_SUMS = '#edits_for_institution'

  def visit_dashboard
    page.visit(DASHBOARD_PATH)
    page.find('h3', text: 'Site-wide edits')
    self
  end

  def item_edit_count(label = 'All')
    count_in(page.find('.card', text: ITEM_EDITS_CARD), label)
  end

  # Picks the institution and waits for the `.js` response to fill the panel.
  def choose_institution(name)
    page.select(name, from: INSTITUTION_SELECT)
    page.all("#{INSTITUTION_SUMS} #{SUM}", minimum: 1)
    self
  end

  def institution_edit_count(label = 'All')
    count_in(page.find(INSTITUTION_SUMS), label)
  end

  private

  # The labels are upper-cased by CSS, so they are matched case-insensitively.
  def count_in(scope, label)
    sum = scope.all(SUM).find { |candidate| candidate.find(SUM_LABEL).text.casecmp?(label) }
    sum.find(SUM_VALUE).text.to_i
  end

  def page
    Capybara.current_session
  end
end
