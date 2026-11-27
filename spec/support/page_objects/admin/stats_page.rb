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
  PENDING_MARKER = '#stats-pending'

  def visit_dashboard
    page.visit(DASHBOARD_PATH)
    page.find('h3', text: 'Site-wide edits')
    self
  end

  def item_edit_count(label = 'All')
    count_in(page.find('.card', text: ITEM_EDITS_CARD), label)
  end

  # Picks the institution and waits for the `.js` response that replaces the panel.
  #
  # Waiting for a `.sum` to exist is not enough: a previous selection's figures are
  # already there, so a read straight after choosing a second institution could
  # return the first one's numbers. The response re-renders the panel's contents, so
  # a marker child placed in it is wiped by the answer and its disappearance is what
  # proves the new figures arrived.
  def choose_institution(name)
    mark_panel_pending
    page.select(name, from: INSTITUTION_SELECT)
    page.document.synchronize do
      next if page.has_no_css?(PENDING_MARKER, wait: 0)

      raise Capybara::ElementNotFound, "the figures for #{name} did not load"
    end
    page.find("#{INSTITUTION_SUMS} #{SUM}", match: :first)
    self
  end

  def institution_edit_count(label = 'All')
    count_in(page.find(INSTITUTION_SUMS), label)
  end

  private

  # A child the response wipes when it re-renders the panel.
  def mark_panel_pending
    page.execute_script(<<~JS)
      var panel = document.querySelector('#{INSTITUTION_SUMS}');
      if (panel) { panel.innerHTML = '<span id="stats-pending"></span>'; }
    JS
  end

  # The labels are upper-cased by CSS, so they are matched case-insensitively.
  def count_in(scope, label)
    sum = scope.all(SUM).find { |candidate| candidate.find(SUM_LABEL).text.casecmp?(label) }
    sum.find(SUM_VALUE).text.to_i
  end

  def page
    Capybara.current_session
  end
end
