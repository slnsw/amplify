# frozen_string_literal: true

RSpec.describe TranscriptSearch do
  let(:project_data) { { 'transcriptsPerPage' => '30' } }
  let(:base_options) { { page: 1, per_page: 30 } }

  before do
    allow(Project).to receive(:getActive).and_return({ uid: 'test', data: project_data })
  end

  describe '#initialize' do
    it 'initializes with default pagination' do
      search = described_class.new(base_options)
      expect(search.transcripts).to be_a(ActiveRecord::Relation)
    end

    it 'applies project_uid filter' do
      search = described_class.new(base_options)
      expect(search.transcripts.to_sql).to include('project_uid')
    end

    it 'filters published transcripts only' do
      search = described_class.new(base_options)
      expect(search.transcripts.to_sql).to include('published_at IS NOT NULL')
    end
  end

  describe 'sorting' do
    it 'defaults to title ascending' do
      search = described_class.new(base_options)
      expect(search.transcripts.to_sql).to include('ORDER BY')
    end

    it 'allows custom sort order' do
      search = described_class.new(base_options.merge(order: 'desc', sort_by: 'title'))
      expect(search.transcripts.to_sql).to include('DESC')
    end
  end

  describe 'filtering' do
    context 'with search term' do
      it 'performs deep search on transcript lines' do
        search = described_class.new(base_options.merge(search: 'test query'))
        expect(search.transcripts.to_sql).to include('transcript_lines')
      end
    end

    context 'with collection filter' do
      it 'filters by collection titles' do
        search = described_class.new(base_options.merge(collections: ['Collection 1']))
        expect(search.transcripts.to_sql).to include('collections.title')
      end
    end

    context 'with institution filter' do
      it 'filters by institution slug' do
        search = described_class.new(base_options.merge(institution: 'test-institution'))
        expect(search.transcripts.to_sql).to include('institutions.slug')
      end
    end
  end
end
