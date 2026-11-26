# frozen_string_literal: true

# Selectors and navigation for the public institution landing page
# (`/:institution_slug`). It deliberately has no assertions and no
# Rails/factory/DB dependency, so the remote staging layer (spec/staging) can
# drive the same object against a real host.
class InstitutionPage
  include ListTexts

  OG_TITLE = 'meta[property="og:title"]'
  HERO_TITLE = '.main_hero__title'
  TRANSCRIPT_TITLES = '.transcript_item__title'
  # The collection facet is a closed dropdown, so its checkboxes are not visible;
  # each checkbox value is the collection title.
  COLLECTION_CHECKBOXES = '#data_collection_id_ input[type="checkbox"]'
  SORT_FIELD = 'sort_by'

  def visit_path(institution_slug)
    page.visit("/#{institution_slug}")
    self
  end

  # The page body never repeats the institution's name; the server-rendered
  # og:title is the only place it appears.
  def institution_name
    page.find(OG_TITLE, visible: false)[:content]
  end

  def hero_title
    page.find(HERO_TITLE).text
  end

  def collection_titles
    page.all(COLLECTION_CHECKBOXES, visible: false).map(&:value)
  end

  def transcript_titles
    texts_for(TRANSCRIPT_TITLES)
  end

  def sort_transcripts(option_title)
    page.select(option_title, from: SORT_FIELD)
    self
  end

  # The filter is a plain GET submit, so the click starts a navigation. Waiting for
  # the list to come from a new document keeps the next read from answering from the
  # document that is being replaced (which still shows the previous order).
  #
  # A marker set on the current document is what distinguishes the two: submitting
  # the same filters leaves the URL unchanged, so waiting for a different URL would
  # hang on a page that reloaded correctly. The script failing because its context
  # was destroyed is the navigation itself.
  def apply_filters
    page.execute_script('window.__filterMarker = true')
    page.click_button('Apply filters')
    page.document.synchronize do
      raise Capybara::ElementNotFound, 'the filtered page has not loaded' if previous_document?
    end
    page.find(TRANSCRIPT_TITLES, match: :first)
    self
  end

  private

  def previous_document?
    page.evaluate_script('typeof window.__filterMarker !== "undefined"')
  rescue Selenium::WebDriver::Error::JavascriptError => e
    raise unless e.message.include?('Execution context was destroyed')

    false
  end

  def page
    Capybara.current_session
  end
end
