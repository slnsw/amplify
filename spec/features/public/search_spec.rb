# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Search' do
  describe 'the search page', :js do
    scenario 'finds a transcript by its line text' do
      world = build_content_world
      SearchPage.new.search_for(world.transcript_lines.first.original_text)

      expect(page).to have_css(SearchPage::RESULT_TITLES, text: world.transcript.title)
    end

    scenario 'shows the empty state for a term that matches nothing' do
      build_content_world
      # Kept free of any trigram that appears in the world's line text: pg_search
      # matches on character trigrams, so "transcript" inside the term would match.
      search_page = SearchPage.new.search_for('zzqqxx vvjjww')

      expect(search_page.empty_state).to eq('No transcripts found')
    end
  end

  describe 'ordering the results without a search term', :js do
    scenario 'lists the transcripts by title by default' do
      world_with_two_transcripts
      search_page = SearchPage.new.visit_path

      expect(search_page.result_titles).to eq(['Alpha interview', 'Zulu interview'])
    end

    scenario 'moves the least complete transcript first when sorted by completeness' do
      world_with_two_transcripts
      search_page = SearchPage.new.visit_path(sort_by: 'completeness', order: 'desc')

      expect(search_page.result_titles.first).to eq('Zulu interview')
    end
  end

  # Titles and completion percentages are chosen so the two orders disagree: by
  # title Alpha leads, by completeness (least complete first) Zulu leads.
  def world_with_two_transcripts
    build_content_world(
      transcript_attributes: { title: 'Zulu interview' },
      extra_transcripts: [{ title: 'Alpha interview', percent_completed: 90 }]
    )
  end
end
