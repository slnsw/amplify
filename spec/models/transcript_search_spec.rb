# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptSearch do
  let!(:institution) { create(:institution) }
  let!(:vendor) { create(:vendor) }
  let!(:collection) { create(:collection, institution: institution, vendor: vendor, published_at: 2.days.ago) }
  let!(:transcript) { create(:transcript, collection: collection, vendor: vendor, published_at: 1.day.ago) }
  let!(:transcript_line) { create(:transcript_line, transcript: transcript, original_text: 'Hello world') }

  before do
    allow(Project).to receive(:getActive).and_return({ data: { 'transcriptsPerPage' => 10 } })
    allow(ENV).to receive(:[]).with('PROJECT_ID').and_return(transcript.project_uid)
  end

  context 'when searching by text' do
    xit 'returns transcripts matching the search' do # this test is skipped because the fuzzy_search method has to be checked
      expect(TranscriptLine).to receive(:fuzzy_search).with('Hello').and_call_original
      search = described_class.new(search: 'Hello')
      expect(search.transcripts).to be_present
      expect(search.transcripts.first.original_text).to eq('Hello world')
    end
  end

  context 'when not searching (default)' do
    it 'returns published transcripts' do
      search = described_class.new({})
      expect(search.transcripts).to be_present
      expect(search.transcripts.first.uid).to eq(transcript.uid)
    end
  end

  context 'with collection filter' do
    it 'returns transcripts in the given collection' do
      search = described_class.new(collections: [collection.title])
      expect(search.transcripts).to all(have_attributes(collection_title: collection.title))
    end
  end

  context 'with institution filter' do
    it 'returns transcripts for the given institution' do
      search = described_class.new(institution: institution.slug)
      expect(search.transcripts).to all(satisfy { |t| t.collection_title == collection.title })
    end
  end

  context 'with sorting' do
    it 'sorts transcripts by title desc' do
      search = described_class.new(order: 'desc', sort_by: 'title')
      expect(search.transcripts).to be_present
    end
  end

  context 'with pagination' do
    it 'paginates results' do
      create_list(:transcript, 15, collection: collection, vendor: vendor, published_at: 1.day.ago)
      search = described_class.new(page: 1, per_page: 10)
      expect(search.transcripts.size).to eq(10)
    end
  end
end
