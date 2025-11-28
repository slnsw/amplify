# frozen_string_literal: true

RSpec.describe CollectionsService, type: :service do
  describe '.list' do
    let!(:institution) { create(:institution, hidden: false) }
    let!(:hidden_institution) { create(:institution, hidden: true) }
    let!(:collection1) { create(:collection, :published, institution: institution) }
    let!(:collection2) { create(:collection, :published, institution: hidden_institution) }

    it 'returns collections with published institutions' do
      result = described_class.list
      expect(result).to include(collection1)
      expect(result).not_to include(collection2)
    end
  end

  describe '.by_institution' do
    let!(:institution) { create(:institution, slug: 'test-inst', hidden: false) }
    let!(:institution2) { create(:institution, slug: 'test-inst-2', hidden: false) }
    let!(:collection) { create(:collection, :published, institution: institution, title: 'Middle Collection') }

    context 'when passing institution slug' do
      it 'shows published collections for that institution' do
        result = described_class.by_institution(institution.slug).to_a
        expect(result).to include(collection)
      end
    end

    context 'when passing institution 2 slug' do
      it 'returns empty array when institution has no collections' do
        expect(described_class.by_institution(institution2.slug).to_a).to eq([])
      end
    end

    context 'when institution slug is blank' do
      let!(:state_library) { create(:institution, slug: 'state-library-nsw', hidden: false) }
      let!(:state_collection) { create(:collection, :published, institution: state_library) }

      before do
        allow(Institution).to receive(:state_library_nsw).and_return(state_library)
      end

      it 'uses state library nsw slug' do
        result = described_class.by_institution(nil).to_a
        expect(result).to include(state_collection)
      end
    end

    it 'orders by title ascending' do
      collection_z = create(:collection, :published, institution: institution, title: 'Z Collection')
      collection_a = create(:collection, :published, institution: institution, title: 'A Collection')

      result = described_class.by_institution(institution.slug).pluck(:title)
      expect(result.first).to eq('A Collection')
      expect(result.last).to eq('Z Collection')
    end
  end
end
