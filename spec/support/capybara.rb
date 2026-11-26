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

# The headless Chrome every local `:js` example drives.
module LocalChrome
  # Wide enough for the desktop layout: the editor's instructions block, the
  # account widget and the admin side panes are hidden below the desktop/tablet
  # breakpoints. It is a launch argument rather than a per-example resize so the
  # size cannot leak from one randomly ordered example into the next.
  WINDOW_SIZE = 'window-size=1400,900'
  # The same browser with Chrome's performance (network) log switched on, for
  # the examples that must prove a request was never sent
  # (`EditorMediaRequests#unaccounted_media_requests`). It is a separate driver
  # so the sessions every other example shares do not accumulate a network log
  # nobody reads.
  NETWORK_DRIVER = :chrome_headless_network

  module_function

  # The project content loads its media from a CDN this environment cannot
  # reach, so the browser is pointed at the local stub instead
  # (spec/support/feature_cdn_stub.rb); the stub's self-signed certificate is
  # why certificate errors are ignored here.
  def driver(app, logging_prefs: { browser: 'ALL' })
    cdn_stub = FeatureCdnStub.start
    options = Selenium::WebDriver::Chrome::Options.new(
      args: [
        'headless', 'disable-gpu', 'no-sandbox', 'disable-dev-shm-usage', WINDOW_SIZE,
        '--ignore-certificate-errors',
        "--host-resolver-rules=MAP #{FeatureCdnStub::HOST} 127.0.0.1:#{cdn_stub.port}"
      ],
      logging_prefs: logging_prefs
    )
    Capybara::Selenium::Driver.new app,
                                   browser: :chrome,
                                   clear_session_storage: true,
                                   clear_local_storage: true,
                                   options: options
  end
end

Capybara.register_driver(:chrome_headless) { |app| LocalChrome.driver(app) }

Capybara.register_driver(LocalChrome::NETWORK_DRIVER) do |app|
  LocalChrome.driver(app, logging_prefs: { browser: 'ALL', performance: 'ALL' })
end

Capybara.javascript_driver = :chrome_headless

require_relative 'capybara_chrome_reset_workaround'

# Use puma instead of webrick for better Ruby 3.4 compatibility
Capybara.server = :puma, { Silent: true }

Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.before(:each, :js) do
    # spec/staging drives a deployed host instead of this process's Rails app, so
    # there is nothing local to visit and no Capybara.app to visit it with.
    next if Capybara.app.nil?

    visit '/'
  end
end
