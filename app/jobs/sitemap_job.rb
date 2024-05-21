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

      # All transcrips
      Transcript.joins(collection: :institution).where("institutions.hidden = ?", false).find_each do |transcript|
        next unless transcript.published?

        add transcript.decorate.path
      end

      Collection.joins(:institution).where("institutions.hidden = ?", false).published.find_each do |collection|
        next unless collection.published?

        add collection.decorate.path
      end

      Institution.published.slugged.find_each do |institution|
        add institution.decorate.path
      end
    end
  end
end
