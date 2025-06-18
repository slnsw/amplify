namespace :sitemap do
  desc "generate sitemap"
  task generate: :environment do |_task, _args|
    SitemapJob.perform_now
  end
end
