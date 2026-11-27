# frozen_string_literal: true

require 'rails_helper'

# DetachedNodeRetry is loaded for its side effect on Capybara, so it is only
# visible through a real browser session: these examples make the driver answer
# the way chromedriver does when the document is replaced mid-command.
RSpec.feature 'Detached node retry', :js do
  before { visit '/' }

  def stale_message
    'unknown error: unhandled inspector error: ' \
      '{"code":-32000,"message":"Node with given id does not belong to the document"}'
  end

  # The first command fails the way a replaced document does and every later one
  # is let through. Returns a lambda reading the call count.
  def fail_first_command
    attempts = 0
    allow(page.driver.browser).to receive(:find_elements).and_wrap_original do |original, *args|
      attempts += 1
      raise Selenium::WebDriver::Error::UnknownError, stale_message if attempts == 1

      original.call(*args)
    end
    -> { attempts }
  end

  # Runs the block while every driver command fails with `message`, then stops
  # failing so the after-example hooks can query the browser themselves.
  def while_commands_fail(message)
    failing = { value: true }
    allow(page.driver.browser).to receive(:find_elements).and_wrap_original do |original, *args|
      raise Selenium::WebDriver::Error::UnknownError, message if failing[:value]

      original.call(*args)
    end
    yield
  ensure
    failing[:value] = false
  end

  scenario 're-issues a find the driver aborted because the document changed', :aggregate_failures do
    attempts = fail_first_command

    expect(page.find('body')).to be_truthy
    expect(attempts.call).to be >= 2
  end

  scenario 're-issues a waiting matcher', :aggregate_failures do
    attempts = fail_first_command

    expect(page).to have_css('body')
    expect(attempts.call).to be >= 2
  end

  scenario 'raises any other UnknownError straight away' do
    expect { while_commands_fail('unknown error: something else') { page.find('body', wait: 0) } }
      .to raise_error(Selenium::WebDriver::Error::UnknownError, /something else/)
  end

  scenario 'raises when the node stays detached past the wait' do
    expect { while_commands_fail(stale_message) { page.find('body', wait: 0.2) } }
      .to raise_error(Selenium::WebDriver::Error::UnknownError, /does not belong to the document/)
  end
end
