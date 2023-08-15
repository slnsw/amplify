require 'capybara/rails'
require 'capybara/rspec'

Webdrivers::Chromedriver.required_version = '114.0.5735.90'

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
    visit '/'
  end
end
