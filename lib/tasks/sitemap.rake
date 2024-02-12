namespace :sitemap do
  desc "generate sitemap"
  task :generate => :environment do |task, args|
    SitemapJob.perform_now
  end
end
