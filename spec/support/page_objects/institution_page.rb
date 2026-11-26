# frozen_string_literal: true

# Selectors and navigation for the public institution landing page
# (`/:institution_slug`). It deliberately has no assertions and no
# Rails/factory/DB dependency, so the remote staging layer (spec/staging) can
# drive the same object against a real host.
class InstitutionPage
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
    page.all(TRANSCRIPT_TITLES).map(&:text)
  end

  def sort_transcripts(option_title)
    page.select(option_title, from: SORT_FIELD)
    self
  end

  def apply_filters
    page.click_button('Apply filters')
    self
  end

  private

  def page
    Capybara.current_session
  end
end
