# frozen_string_literal: true

# Waits for the browser to be showing a different document than the one on screen
# now.
#
# A form whose response redirects back to the same URL leaves almost no trace of
# the navigation: the URL is unchanged and the values the form was filled with are
# already in the DOM, so a read can answer from the page that is being replaced and
# prove only that the fields were typed into. The marker set on the current
# document is what tells the two apart. The script failing because its context was
# destroyed says the navigation has begun, not that it has finished, so the new
# document is also waited for.
#
# Including page objects only need the private `page` method they all define.
module DocumentWaits
  MARKER = 'window.__documentMarker = true'

  private

  def wait_for_new_document
    page.execute_script(MARKER)
    yield
    page.document.synchronize do
      raise Capybara::ElementNotFound, 'the page did not reload' unless reloaded?
    end
  end

  # True once the marker is gone and the document that replaced it has a DOM.
  #
  # The marker lives in the old document, so reading it raises once the browser
  # starts tearing that document down. That raise means the navigation has begun,
  # not that it has finished: treating it as finished returned into a blank page
  # the next read could see nothing in. Both conditions are checked in one script,
  # and the raise is a "not yet". `interactive` is enough: the staging driver returns
  # at DOMContentLoaded, so waiting for `complete` would hang on a page whose media
  # never finishes loading.
  def reloaded?
    page.evaluate_script("typeof window.__documentMarker === 'undefined' && document.readyState !== 'loading'")
  rescue Selenium::WebDriver::Error::JavascriptError => e
    raise unless e.message.include?('Execution context was destroyed')

    false
  end
end
