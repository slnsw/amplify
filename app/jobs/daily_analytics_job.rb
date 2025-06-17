# frozen_string_literal: true

class DailyAnalyticsJob < ApplicationJob
  queue_as :default

  def perform
    # cache analytics data
    Rails.cache.delete('Institution:disk_usage:all')
    Institution.all_institution_disk_usage
  end
end
