Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379",
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"] || "redis://localhost:6379",
  }
end

unless %w(test development).include?(Rails.env)
  Sidekiq::Cron::Job.create(
    name: "Cache Analytics data - at 4PM UTC",
    cron: "0 16 * * *",
    class: "DailyAnalyticsJob",
  )

  Sidekiq::Cron::Job.create(
    name: "Recalculate transcript analytics data",
    cron: "0 1,13 * * *",
    class: "RecalculateTranscriptsJob",
  )

	Sidekiq::Cron::Job.create(
    name: "Creates or updates xml sitemap",
    cron: "0 0 * * *",
    class: "SitemapJob",
  )
end
