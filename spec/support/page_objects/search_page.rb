# frozen_string_literal: true

require 'uri'

# Selectors and navigation for the public search page (`/search`). It
# deliberately has no assertions and no Rails/factory/DB dependency, so the
# remote staging layer (spec/staging) can drive the same object against a real
# host.
class SearchPage
  RESULT_TITLES = '.search_item__title'
  EMPTY_STATE = '.search_results .cms'
  SEARCH_FIELD = 'search'
  SEARCH_BUTTON = 'Start'

  # Query parameters the server-rendered page understands: `search` (deep search
  # over transcript lines), `sort_by` and `institution`/`collections`.
  def visit_path(params = {})
    query = params.empty? ? '' : "?#{URI.encode_www_form(params)}"
    page.visit("/search#{query}")
    self
  end

  def search_for(term)
    visit_path
    page.fill_in(SEARCH_FIELD, with: term)
    page.click_button(SEARCH_BUTTON)
    self
  end

  def result_titles
    page.all(RESULT_TITLES).map(&:text)
  end

  def empty_state
    page.find(EMPTY_STATE).text
  end

  private

  def page
    Capybara.current_session
  end
end
