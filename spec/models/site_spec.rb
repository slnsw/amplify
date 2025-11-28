# frozen_string_literal: true

RSpec.describe Site, type: :model do
  describe 'instance methods' do
    let(:site) { described_class.new }

    before do
      FactoryBot.create(:page, page_type: 'footer', published: true)
    end

    describe '#footer_content' do
      context 'when footer page exists' do
        it 'returns the footer content' do
          expect(site.footer_content).not_to be_empty
        end
      end
    end

    describe '#footer_links' do
      it 'returns an array of links' do
        expect(site.footer_links).to be_an(Array)
      end
    end
  end
end
