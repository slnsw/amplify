# frozen_string_literal: true

# Retries a Capybara command that chromedriver aborts because the document was
# replaced underneath it.
#
# A full page load can still be swapping `document` when the next command runs
# (the institution form posts and redirects, for instance). Chromedriver then
# answers "Node with given id does not belong to the document" as a generic
# Selenium `UnknownError`, and Capybara's retry loop only recognises
# `ElementNotFound` and `driver.invalid_element_errors`, so the example fails on
# a page that is merely still settling.
#
# `catch_error?` is the single hook every retry loop in Capybara consults, so
# recognising this one message there puts finds, matchers, `all` reads and
# clicks inside the loop: the command is re-issued against the new document
# instead of failing the example. Anything else chromedriver reports as an
# `UnknownError` still raises immediately, and a node that stays detached past
# `Capybara.default_max_wait_time` still raises.
module DetachedNodeRetry
  STALE_NODE = 'Node with given id does not belong to the document'

  private

  def catch_error?(error, errors = nil)
    return true if stale_node?(error)

    super
  end

  def stale_node?(error)
    defined?(Selenium::WebDriver::Error::UnknownError) &&
      error.is_a?(Selenium::WebDriver::Error::UnknownError) &&
      error.message.include?(STALE_NODE)
  end
end

Capybara::Node::Base.prepend(DetachedNodeRetry)
