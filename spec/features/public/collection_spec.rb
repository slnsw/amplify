# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Collection page', :js do
  scenario 'shows the transcripts of the collection', :aggregate_failures do
    world = build_content_world
    collection_page = CollectionPage.new.visit_path(world.institution.slug, world.collection.uid)

    expect(collection_page.transcript_titles).to eq([world.transcript.title])
    expect(collection_page.collection_filter_label).to eq('Collections (1)')
  end

  # app/assets/javascripts/collections.js POSTs /collections/list on load and on
  # every institution change; the endpoint answers with list.js.erb, which fills
  # `.collect-list`. A second institution is what shows the answer is filtered:
  # with one institution a reply that ignored the selection looks the same.
  # rubocop:disable RSpec/ExampleLength
  scenario 'lists only the collections of the institution chosen in the page JS', :aggregate_failures do
    world = build_content_world
    other = build_content_world
    collection_page = CollectionPage.new.visit_index

    collection_page.choose_institution(world.institution.name)

    expect(page).to have_css(CollectionPage::LISTED_COLLECTION_TITLES, text: world.collection.title)
    expect(page).to have_no_css(CollectionPage::LISTED_COLLECTION_TITLES, text: other.collection.title)
  end
  # rubocop:enable RSpec/ExampleLength
end
