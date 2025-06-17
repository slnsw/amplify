# frozen_string_literal: true

RSpec.describe CollectionsService, type: :service do
  describe '.by_institution' do
    let!(:institution) { create :institution }
    let!(:institution2) { create :institution }
    let!(:collection) { create :collection, institution: institution }

    context 'when passing institution id' do
      it 'shows the correct collection' do
        expect(described_class.by_institution(institution.slug).to_a)
          .to eq([collection])
      end
    end

    context 'when passing institution 2 id' do
      it 'shows the empty collection' do
        expect(described_class.by_institution(institution2.slug).to_a).to eq([])
      end
    end
  end
end
