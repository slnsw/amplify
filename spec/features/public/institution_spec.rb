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

    # One world proves nothing about isolation: a second institution with its own
    # published item is what shows the page is filtered to the institution in the
    # path. The other item's absence below only means something because its own
    # page lists it, so the record is visible rather than unpublished.
    # rubocop:disable RSpec/ExampleLength
    scenario 'lists only the items of the institution in the path', :aggregate_failures do
      world = build_content_world
      other = build_content_world

      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      expect(institution_page.collection_titles).to eq([world.collection.title])
      expect(institution_page.transcript_titles).to eq([world.transcript.title])
      expect(page).not_to have_text(other.transcript.title)

      InstitutionPage.new.visit_path(other.institution.slug)
      expect(page).to have_text(other.transcript.title)
    end
    # rubocop:enable RSpec/ExampleLength

    # The default order is `randomize_list` (`Transcript.apply_sorting_to_query`),
    # so an ignored selection would still put the expected title first about half
    # the time and the example would pass for the wrong reason. The submitted
    # query is what proves the selection was sent; the full order is what proves
    # it was applied.
    scenario 're-orders the transcripts by title', :aggregate_failures do
      world = world_with_two_transcripts
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      institution_page.sort_transcripts('Title (A to Z)').apply_filters

      expect(page).to have_current_path(/sort_by=title_asc/, url: true)
      expect(institution_page.transcript_titles).to eq(['Alpha interview', 'Zulu interview'])
    end

    scenario 're-orders the transcripts by completeness', :aggregate_failures do
      world = world_with_two_transcripts
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      institution_page.sort_transcripts('Completeness (most to least)').apply_filters

      expect(page).to have_current_path(/sort_by=percent_completed_desc/, url: true)
      expect(institution_page.transcript_titles).to eq(['Zulu interview', 'Alpha interview'])
    end

    # Submitting the filters a second time reloads the URL the first submission
    # produced, so waiting for the URL to differ would hang on a page that did
    # exactly what was asked.
    scenario 'keeps the list when the same filters are submitted again' do
      world = world_with_two_transcripts
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      institution_page.apply_filters.apply_filters

      expect(institution_page.transcript_titles).to contain_exactly('Alpha interview', 'Zulu interview')
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
