# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Static pages', :js do
  scenario 'renders the configured FAQ content' do
    build_content_world(pages: { 'faq' => '<p>Transcripts are corrected one line at a time.</p>' })

    visit '/page/faq'

    expect(page).to have_css('.cms', text: 'Transcripts are corrected one line at a time.')
  end

  scenario 'renders the configured about content' do
    build_content_world(pages: { 'about' => '<p>Amplify is a crowdsourcing platform from the State Library.</p>' })

    visit '/page/about'

    expect(page).to have_css('.cms', text: 'Amplify is a crowdsourcing platform from the State Library.')
  end

  scenario 'renders the configured content of a page looked up by id' do
    build_content_world(pages: { 'collecting-stories' => '<p>Collecting Stories records oral histories.</p>' })

    visit '/page/collecting-stories'

    expect(page).to have_css('.cms', text: 'Collecting Stories records oral histories.')
  end
end
