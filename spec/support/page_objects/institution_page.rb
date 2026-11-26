# frozen_string_literal: true

require_relative 'document_waits'

# Selectors and navigation for the public institution landing page
# (`/:institution_slug`). It deliberately has no assertions and no
# Rails/factory/DB dependency, so the remote staging layer (spec/staging) can
# drive the same object against a real host.
class InstitutionPage
  include ListTexts

  include DocumentWaits

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

  # The collection facet renders a hidden checkbox per collection, named
  # `collections[]` with the collection title as its value. It is not visible until
  # the dropdown is opened, so it is ticked through the DOM; the change event is
  # dispatched so the facet's own label stays in step.
  def filter_by_collection(title)
    page.execute_script(<<~JS, title)
      var box = document.querySelector("#data_collection_id_ input[value='" + arguments[0] + "']");
      box.checked = true;
      box.dispatchEvent(new Event('change', { bubbles: true }));
    JS
    self
  end

  def sort_transcripts(option_title)
    page.select(option_title, from: SORT_FIELD)
    self
  end

  # The filter is a plain GET submit, so the click starts a navigation. Waiting for
  # the list to come from a new document keeps the next read from answering from the
  # document that is being replaced (which still shows the previous order), and
  # submitting the same filters reloads the same URL, so the URL cannot be the test.
  def apply_filters
    wait_for_new_document { page.click_button('Apply filters') }
    page.find(TRANSCRIPT_TITLES, match: :first)
    self
  end

  private

  def page
    Capybara.current_session
  end
end
