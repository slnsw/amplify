# frozen_string_literal: true

# Waits for the browser to be showing a different document than the one on screen
# now.
#
# A form whose response redirects back to the same URL leaves almost no trace of
# the navigation: the URL is unchanged and the values the form was filled with are
# already in the DOM, so a read can answer from the page that is being replaced and
# prove only that the fields were typed into. The marker set on the current
# document is what tells the two apart; the script failing because its context was
# destroyed is the navigation itself.
#
# Including page objects only need the private `page` method they all define.
module DocumentWaits
  MARKER = 'window.__documentMarker = true'
  MARKER_PRESENT = 'typeof window.__documentMarker !== "undefined"'

  private

  def wait_for_new_document
    page.execute_script(MARKER)
    yield
    page.document.synchronize do
      raise Capybara::ElementNotFound, 'the page did not reload' if marked_document?
    end
  end

  def marked_document?
    page.evaluate_script(MARKER_PRESENT)
  rescue Selenium::WebDriver::Error::JavascriptError => e
    raise unless e.message.include?('Execution context was destroyed')

    false
  end
end
