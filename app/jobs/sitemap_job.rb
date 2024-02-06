class SitemapJob < ApplicationJob
  queue_as :default

  def perform
    # Set the host name for URL creation
		SitemapGenerator::Sitemap.default_host = ENV['SITEMAP_HOSTNAME'] || "https://amplify.gov.au"

		SitemapGenerator::Sitemap.create do
			# Put links creation logic here.
			#
			# The root path '/' and sitemap index file are added automatically for you.
			# Links are added to the Sitemap in the order they are specified.
			#
			# Usage: add(path, options={})
			#        (default options are used if you don't specify)
			#
			# Defaults: :priority => 0.5, :changefreq => 'weekly',
			#           :lastmod => Time.now, :host => default_host
			#
			# Examples:
			#
			# Add '/articles'
			#
			#   add articles_path, :priority => 0.7, :changefreq => 'daily'
			#
			# Add all articles:
			#
			#   Article.find_each do |article|
			#     add article_path(article), :lastmod => article.updated_at
			#   end
			add '/search', priority: 0.75
			add '/collections', priority: 0.6
			add '/page/about', priority: 0.5
			add '/page/faq', priority: 0.5
			add '/page/tutorial', priority: 0.4
			add '/disclaimer', priority: 0.3
			add '/privacy', priority: 0.3
			add '/copyright', priority: 0.3
			add '/right-to-information', priority: 0.3
			add '/website-accessibility', priority: 0.3
			add '/feedback', priority: 0.3

			# All transcrips
			Transcript.find_each do |transcript|
				add institution_transcript_path(
					collection: transcript.collection,
					institution: transcript.collection.institution,
					id: transcript.id
					), lastmod: transcript.updated_at
			end

			# All institution
			Institution.find_each do |institution|
				next unless institution.slug.present?

				add institution_path(institution.slug), lastmod: institution.updated_at
			end
		end
  end
end
