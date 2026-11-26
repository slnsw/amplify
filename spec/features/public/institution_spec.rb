# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Public institution journeys' do
  describe 'the institution landing page', :js do
    scenario 'shows the institution name and its hero copy', :aggregate_failures do
      world = build_content_world
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      expect(institution_page.institution_name).to eq(world.institution.name)
      expect(institution_page.hero_title).to eq(world.institution.introductory_text)
    end

    scenario 'lists the collections and transcripts of the institution', :aggregate_failures do
      world = build_content_world
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      expect(institution_page.collection_titles).to eq([world.collection.title])
      expect(institution_page.transcript_titles).to eq([world.transcript.title])
    end

    scenario 're-orders the transcripts by title' do
      world = world_with_two_transcripts
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      institution_page.sort_transcripts('Title (A to Z)').apply_filters
      expect(institution_page.transcript_titles.first).to eq('Alpha interview')
    end

    scenario 're-orders the transcripts by completeness' do
      world = world_with_two_transcripts
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      institution_page.sort_transcripts('Completeness (most to least)').apply_filters
      expect(institution_page.transcript_titles.first).to eq('Zulu interview')
    end
  end

  describe 'an unknown path' do
    scenario 'falls through to institutions#index and renders the 404 page', :aggregate_failures do
      # config/routes.rb ends with `match '*path' => 'institutions#index'`, so an
      # unknown path reaches InstitutionsController#index, which raises
      # RecordNotFound for the unknown slug. That has to surface as the app's own
      # 404 page, never as a 500.
      expect(Rails.application.routes.recognize_path('/definitely-not-a-real-path'))
        .to include(controller: 'institutions', action: 'index')

      visit '/definitely-not-a-real-path'

      expect(page.status_code).to eq(404)
      expect(page).to have_css('.exception[data-status="404"]')
    end
  end

  # Titles and completion percentages are chosen so the two sort orders disagree:
  # by title Alpha leads, by completeness (most to least) Zulu leads.
  def world_with_two_transcripts
    build_content_world(
      transcript_attributes: { title: 'Alpha interview' },
      extra_transcripts: [{ title: 'Zulu interview', percent_completed: 90 }]
    )
  end
end
