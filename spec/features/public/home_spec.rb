# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home page', :js do
  # The item image is a CSS background, so its element renders whether or not the
  # file arrives. The browser's own resource log is what says the image loaded;
  # the element alone passes on a 404.
  scenario 'lists a published transcript with its title and image', :aggregate_failures, :smoke do
    world = build_content_world
    visit root_path

    expect(page).to have_text(world.transcript.title)
    expect(page).to have_css('.transcript_item__image', minimum: 1)
    expect(image_response_statuses).to include(200)
  end

  scenario 'shows the empty state when nothing is published' do
    build_content_world(published: false)
    visit root_path
    expect(page).to have_text('No transcripts found, please make another selection.')
  end

  # The empty state above unpublishes the collection as well, so it reads the
  # same whether or not the homepage filters the item itself: the collection
  # filter is enough to hide it. This keeps the collection published and
  # unpublishes only the item, which is the transcript-level check.
  scenario 'hides an unpublished item whose collection is published', :aggregate_failures do
    world = build_content_world(published: false, collection_published: true)
    visit root_path
    expect(page).to have_text('No transcripts found, please make another selection.')
    expect(page).not_to have_text(world.transcript.title)
  end

  private

  # Every image the browser fetched, with the status it was answered with.
  def image_response_statuses
    page.evaluate_script(<<~JS)
      performance.getEntriesByType('resource')
        .filter(function (entry) { return entry.name.indexOf('/images/') !== -1; })
        .map(function (entry) { return entry.responseStatus; })
    JS
  end
end
