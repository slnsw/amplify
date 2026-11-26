# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Collection page', :js do
  scenario 'shows the transcripts of the collection', :aggregate_failures do
    world = build_content_world
    collection_page = CollectionPage.new.visit_path(world.institution.slug, world.collection.uid)

    expect(collection_page.transcript_titles).to eq([world.transcript.title])
    expect(collection_page.collection_filter_label).to eq('Collections (1)')
  end

  scenario 'lists the institution collections through the page JS' do
    world = build_content_world
    collection_page = CollectionPage.new.visit_index

    # app/assets/javascripts/collections.js POSTs /collections/list on load and on
    # every institution change; the endpoint answers with list.js.erb, which
    # fills `.collect-list`.
    collection_page.choose_institution(world.institution.name)

    expect(page).to have_css(CollectionPage::LISTED_COLLECTION_TITLES, text: world.collection.title)
  end
end
