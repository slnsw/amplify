# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home page', :js do
  # The item renders a fallback element when it has no image, so simply finding
  # `.transcript_item__image` says nothing about a thumbnail. This requires the
  # `<img>` to exist with a `src`, then requires the browser to have finished
  # loading that exact URL: the element alone passes on a 404.
  scenario 'lists a published transcript with its title and image', :aggregate_failures, :smoke do
    world = build_content_world
    visit root_path

    expect(page).to have_text(world.transcript.title)
    expect(page).to have_css('img.transcript_item__image[src]', minimum: 1)
    expect(loaded_image_status(thumbnail_url)).to eq(200)
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

  # The tag's `src` property, which the browser resolves to an absolute URL.
  def thumbnail_url
    page.evaluate_script("document.querySelector('img.transcript_item__image').src")
  end

  # Waits for the browser to finish the request for that exact URL. `loading="lazy"`
  # starts it after the element renders, and the log holds every image the page
  # fetched, so the entry is matched by URL rather than by a path fragment that any
  # other image would satisfy.
  def loaded_image_status(url)
    page.document.synchronize do
      status = page.evaluate_script(<<~JS, url)
        (function (url) {
          var entry = performance.getEntriesByType('resource').find(function (e) { return e.name === url; });
          return entry ? entry.responseStatus : null;
        })(arguments[0])
      JS
      raise Capybara::ElementNotFound, "the browser has not finished loading #{url}" if status.nil?

      status
    end
  end
end
