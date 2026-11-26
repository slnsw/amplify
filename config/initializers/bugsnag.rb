# frozen_string_literal: true

Bugsnag.configure do |config|
  # BUGSNUG_API_KEY is the misspelling this app has used since 2023; keeping it as a fallback means a
  # host that already defines it keeps reporting while the conventional name is rolled out.
  config.api_key = ENV['BUGSNAG_API_KEY'].presence || ENV['BUGSNUG_API_KEY'].presence

  # Defaults to Rails.env, which is the same on every host when RAILS_ENV is 'production'.
  release_stage = ENV['BUGSNAG_RELEASE_STAGE'].presence
  config.release_stage = release_stage if release_stage
end
