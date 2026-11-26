# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home page', :js do
  scenario 'lists a published transcript with its title and image', :aggregate_failures, :smoke do
    world = build_content_world
    visit root_path
    expect(page).to have_text(world.transcript.title)
    expect(page).to have_css('.transcript_item__image', minimum: 1)
  end

  scenario 'shows the empty state when nothing is published' do
    build_content_world(published: false)
    visit root_path
    expect(page).to have_text('No transcripts found, please make another selection.')
  end
end
