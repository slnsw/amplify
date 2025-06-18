require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Selenium::WebDriver::Chrome::Service.driver_path = ENV.fetch("CHROME_DRIVER_PATH", "/usr/bin/chromedriver")

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
                                   args: %w[headless disable-gpu no-sandbox],
                                 )
end

Capybara.javascript_driver = :chrome_headless

Capybara.server = :webrick

RSpec.configure do |config|
  config.before(:each, js: true) do
    visit "/"
  end
end
