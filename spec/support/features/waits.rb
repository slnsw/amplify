# frozen_string_literal: true

# Shared waits for the Backbone/Marionette transcript editor, which renders
# client-side after fetching its data over AJAX. Capybara's normal waiting
# assertions (e.g. `have_css`) cover most cases, but the editor's own boot
# sequence and in-flight jQuery requests need explicit helpers so later specs
# don't race the client-side render.
module Waits
  # jQuery selector for the scroll animation `centerOn` runs while selecting a line.
  SCROLL_ANIMATION = 'jQuery("html, body").is(":animated")'
  # True once the page has no jQuery request in flight (or no jQuery at all).
  AJAX_IDLE = 'typeof jQuery === "undefined" || jQuery.active === 0'

  AjaxStillActive = Class.new(StandardError)

  # The editor view (app.views.TranscriptEdit, see
  # gulp/js/views/transcript.js#renderLines) renders into `#main` and appends
  # one `.line` element per transcript line inside `#transcript-lines`
  # (see gulp/templates/transcripts/transcript_edit.ejs). Waiting for at
  # least one `.line` row confirms the editor has fetched its data and
  # finished its initial render.
  def wait_for_editor_boot(timeout: Capybara.default_max_wait_time)
    return if page.has_css?('#transcript-lines .line', wait: timeout)

    raise "Transcript editor did not boot: no '.line' rows appeared in " \
          "'#transcript-lines' within #{timeout}s"
  end

  # Waits until the page's jQuery has no active AJAX requests left, so the
  # next interaction doesn't race code still waiting on a response. It polls
  # through Capybara rather than `Timeout.timeout`, which could interrupt a
  # Selenium HTTP call half-way through and leave the session unusable.
  def wait_for_ajax_settle(timeout: Capybara.default_max_wait_time)
    page.document.synchronize(timeout, errors: [AjaxStillActive]) do
      next if page.evaluate_script(AJAX_IDLE)

      raise AjaxStillActive, "jQuery requests were still active after #{timeout}s"
    end
  end

  # `lineSelect` re-centres the selected line with a 500ms jQuery scroll
  # animation (gulp/js/views/transcript.js#centerOn), so an interaction
  # dispatched while the page is still moving can land on another line.
  def wait_for_scroll_to_finish
    page.document.synchronize do
      raise Capybara::ElementNotFound, 'the editor is still scrolling' if page.evaluate_script(SCROLL_ANIMATION)
    end
  end
end

RSpec.configure do |config|
  config.include Waits, :js
end
