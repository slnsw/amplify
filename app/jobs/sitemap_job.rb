class SitemapJob < ApplicationJob
  queue_as :default

  def perform
    SitemapGenerator::Sitemap.default_host = ENV['SITEMAP_HOSTNAME'] || "https://amplify.gov.au"

    SitemapGenerator::Sitemap.create do
      add '/search', priority: 0.75
      add '/collections', priority: 0.75
      add '/page/about', priority: 0.3
      add '/page/faq', priority: 0.3
      add '/page/tutorial', priority: 0.3
      add '/disclaimer', priority: 0.3
      add '/right-to-information', priority: 0.3
      add '/website-accessibility', priority: 0.3

      # All transcrips
      Transcript.find_each do |transcript|
        next unless transcript.published?

        add transcript.decorate.path
      end

      Collection.published.find_each do |collection|
        next unless collection.published?

        add collection.decorate.path
      end

      Institution.slugged.find_each do |institution|
        add institution.decorate.path
      end
    end
  end
end
