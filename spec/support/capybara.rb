# frozen_string_literal: true
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

# Selenium 4.6+ ships Selenium Manager, which locates/downloads the correct
# chromedriver automatically. The deprecated `webdrivers` gem is no longer
# required (and it pinned rubyzip to a vulnerable version).

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    clear_session_storage: true,
    clear_local_storage: true,
    options: Selenium::WebDriver::Chrome::Options.new
end

Capybara.register_driver :chrome_headless do |app|
  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    clear_session_storage: true,
    clear_local_storage: true,
    options: Selenium::WebDriver::Chrome::Options.new(
      args: %w[headless disable-gpu no-sandbox disable-dev-shm-usage],
    )
end

Capybara.javascript_driver = :chrome_headless

# Use puma instead of webrick for better Ruby 3.4 compatibility
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, js: true) do
    visit '/'
  end
end
