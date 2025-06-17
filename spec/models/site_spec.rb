# frozen_string_literal: true

RSpec.describe Site, type: :model do
  let(:site) { Site.new }

  before do
    FactoryBot.create(:page, page_type: 'footer', published: true)
  end

  context 'footer content' do
    it 'has footer content' do
      expect(site.footer_content).not_to be_empty
    end
  end

  context 'footer links' do
    it 'has footer content' do
      expect(site.footer_links).to be_kind_of(Array)
    end
  end
end
