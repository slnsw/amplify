# frozen_string_literal: true

# Fails any `js: true` feature example if the headless Chrome console logged
# a SEVERE entry (uncaught exceptions, `console.error`, network errors from
# fetch/XHR, etc). Without this, a broken JS bundle can still leave the page
# looking fine to Capybara's DOM assertions while the editor is silently dead.
#
# spec/features/routing/javascript_health_spec.rb proves the hook still fires:
# if a Chrome/chromedriver release stops exposing the log, that self-test fails
# instead of every `:js` example silently passing.
module JavascriptErrors
  SEVERE_LOG_LEVEL = 'SEVERE'

  # Reads the browser's console log (accumulated since the last time it was
  # read) and raises, listing every SEVERE entry's message and source.
  def expect_no_javascript_errors
    entries = javascript_console_entries
    record_javascript_console_entries(entries)
    errors = entries.select { |entry| entry.level == SEVERE_LOG_LEVEL }
    return if errors.empty?

    details = errors.map { |entry| "  [#{entry.level}] #{entry.message}" }.join("\n")
    raise "JavaScript console reported #{errors.size} error(s):\n#{details}"
  end

  # Warns once per run, naming the driver, when the browser's console log cannot
  # be read: the examples still run, but none of them is checked for JS errors.
  # The reason is also recorded on the example so the staging report can say a
  # journey had no console evidence rather than leaving an empty section that
  # reads as a clean console (spec/staging/report_formatter.rb).
  def self.warn_log_unavailable(driver, reason)
    example = RSpec.current_example
    example&.metadata&.[]=(:javascript_console_unavailable, reason)
    @warned ||= {}
    return if @warned[driver]

    @warned[driver] = true
    Kernel.warn(<<~MESSAGE)
      WARNING: the #{driver} browser does not expose its console log (#{reason}).
      JavaScript errors are NOT being checked for :js examples on this driver.
    MESSAGE
  end

  private

  # Reading the log clears it, so the entries are kept on the example for the
  # staging report's console appendix (spec/staging/report_formatter.rb). An
  # example can read the log more than once (an explicit check, then the after
  # hook), so each read appends rather than replacing the earlier entries.
  def record_javascript_console_entries(entries)
    example = RSpec.current_example
    return if example.nil?

    recorded = example.metadata[:javascript_console_entries] ||= []
    recorded.concat(entries.map { |entry| "[#{entry.level}] #{entry.message}" })
  end

  # Reading the log must not start a browser of its own. A skipped example never
  # opened one, and `page.driver.browser` would launch Chrome - turning the skip
  # into a failure whenever the browser cannot start, which is not what a skip
  # means. A session that never started has no log, so there is nothing to report.
  # The driver is built lazily and so is the browser; asking whether one exists is
  # the only way to tell them apart without launching it.
  def browser_started?(driver)
    driver.respond_to?(:browser) && !driver.instance_variable_get(:@browser).nil?
  end

  def javascript_console_entries
    driver = page.driver
    return [] unless browser_started?(driver)

    browser = driver.browser
    unless browser.respond_to?(:logs)
      JavascriptErrors.warn_log_unavailable(Capybara.current_driver, 'the driver has no logs API')
      return []
    end

    browser.logs.get(:browser)
  rescue Selenium::WebDriver::Error::WebDriverError => e
    JavascriptErrors.warn_log_unavailable(Capybara.current_driver, "#{e.class}: #{e.message.lines.first&.strip}")
    []
  end
end

RSpec.configure do |config|
  config.include JavascriptErrors, :js

  config.after(:each, :js) do
    expect_no_javascript_errors
  end
end
