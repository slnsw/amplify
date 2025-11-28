# frozen_string_literal: true

RSpec.describe CollectionDecorator, type: :decorator do
  let(:institution) { create(:institution, slug: 'test-institution') }
  let(:collection) { create(:collection, institution: institution, uid: 'test-collection') }
  let(:decorator) { collection.decorate }

  describe '#transcript_items' do
    it 'returns the count of transcripts' do
      create_list(:transcript, 3, collection: collection)
      expect(decorator.transcript_items).to eq(3)
    end

    it 'returns zero when no transcripts' do
      expect(decorator.transcript_items).to eq(0)
    end
  end

  describe '#path' do
    it 'returns the collection path' do
      expect(decorator.path).to eq('/test-institution/test-collection')
    end
  end

  describe '#absolute_url' do
    before do
      allow(Rails.application.config.action_controller).to receive(:default_url_options)
        .and_return({ host: 'test.host' })
    end

    it 'returns the absolute URL for the collection' do
      url = decorator.absolute_url
      expect(url).to include('test-collection')
      expect(url).to include('http')
    end
  end
end
