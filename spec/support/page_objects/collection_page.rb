# frozen_string_literal: true

# Selectors and navigation for the public collection pages: the collection
# listing (`/collections`) and a single collection's transcripts
# (`/:institution_slug/:collection_uid`, the path CollectionDecorator#path
# builds). It deliberately has no assertions and no Rails/factory/DB
# dependency, so the remote staging layer (spec/staging) can drive the same
# object against a real host.
class CollectionPage
  LISTED_COLLECTION_TITLES = '.collect-list .collection-item h3'
  TRANSCRIPT_TITLES = '.transcript_item__title'
  COLLECTION_FILTER = '#collection-filter'

  def visit_index
    page.visit('/collections')
    self
  end

  def visit_path(institution_slug, collection_uid)
    page.visit("/#{institution_slug}/#{collection_uid}")
    self
  end

  # The listing's own JS reloads `.collect-list` over POST /collections/list
  # whenever this select changes.
  def choose_institution(institution_name)
    page.select(institution_name, from: 'institution')
    self
  end

  def collection_filter_label
    page.find(COLLECTION_FILTER).text
  end

  def transcript_titles
    page.all(TRANSCRIPT_TITLES).map(&:text)
  end

  private

  def page
    Capybara.current_session
  end
end
