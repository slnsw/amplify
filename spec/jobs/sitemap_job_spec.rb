# frozen_string_literal: true

RSpec.describe SitemapJob, type: :job do
  describe '#perform' do
    before do
      allow(SitemapGenerator::Sitemap).to receive(:default_host=)
      allow(SitemapGenerator::Sitemap).to receive(:create)
    end

    it 'sets the default host from ENV' do
      ENV['SITEMAP_HOSTNAME'] = 'https://test.example.com'
      described_class.perform_now
      expect(SitemapGenerator::Sitemap).to have_received(:default_host=).with('https://test.example.com')
      ENV.delete('SITEMAP_HOSTNAME')
    end

    it 'uses default host when ENV is not set' do
      ENV.delete('SITEMAP_HOSTNAME')
      described_class.perform_now
      expect(SitemapGenerator::Sitemap).to have_received(:default_host=).with('https://amplify.gov.au')
    end

    it 'calls sitemap create' do
      described_class.perform_now
      expect(SitemapGenerator::Sitemap).to have_received(:create)
    end
  end
end
