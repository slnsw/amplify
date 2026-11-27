# frozen_string_literal: true

require_relative '../features/waits'

# Selectors and navigation for the public collection pages: the collection
# listing (`/collections`) and a single collection's transcripts
# (`/:institution_slug/:collection_uid`, the path CollectionDecorator#path
# builds). It deliberately has no assertions and no Rails/factory/DB
# dependency, so the remote staging layer (spec/staging) can drive the same
# object against a real host.
class CollectionPage
  include ListTexts

  include Waits

  LISTED_COLLECTION_TITLES = '.collect-list .collection-item h3'
  TRANSCRIPT_TITLES = '.transcript_item__title'
  COLLECTION_FILTER = '#collection-filter'
  LIST = '.collect-list'
  PENDING_MARKER = '#collections-pending'

  def visit_index
    page.visit('/collections')
    self
  end

  def visit_path(institution_slug, collection_uid)
    page.visit("/#{institution_slug}/#{collection_uid}")
    self
  end

  # The listing's own JS reloads `.collect-list` over POST /collections/list on
  # load and whenever this select changes, and each response replaces the list
  # without comparing requests - so the load's answer can land after the change's
  # and overwrite it. The load is drained first, then a marker child is placed in
  # the list and awaited: the response wipes it, so its disappearance is what
  # proves the answer for this selection arrived.
  def choose_institution(institution_name)
    wait_for_ajax_settle
    mark_list_pending
    page.select(institution_name, from: 'institution')
    page.document.synchronize do
      next if page.has_no_css?(PENDING_MARKER, wait: 0)

      raise Capybara::ElementNotFound, "the collections for #{institution_name} did not load"
    end
    wait_for_ajax_settle
    self
  end

  def mark_list_pending
    page.execute_script(<<~JS)
      var list = document.querySelector('#{LIST}');
      if (list) { list.innerHTML = '<span id="collections-pending"></span>'; }
    JS
  end

  def collection_filter_label
    page.find(COLLECTION_FILTER).text
  end

  def transcript_titles
    texts_for(TRANSCRIPT_TITLES)
  end

  private

  def page
    Capybara.current_session
  end
end
