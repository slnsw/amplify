# frozen_string_literal: true

RSpec.describe PublicPageDecorator, type: :decorator do
  let(:page) { create(:page, content: '<p>Test content</p>') }
  let(:public_page) { create(:public_page, page: page, content: '<p>Public content</p>') }
  let(:decorator) { public_page.decorate }

  describe '#display_content' do
    it 'returns raw HTML content' do
      allow(decorator).to receive(:h).and_return(double(raw: public_page.content))
      expect(decorator.display_content).to eq('<p>Public content</p>')
    end
  end
end
