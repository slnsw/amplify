# frozen_string_literal: true

require 'json'
require 'securerandom'

# Proves a negative for the transcript editor: that it fetched no audio. Mixed
# into TranscriptEditorPage, which supplies `page`.
#
# The editor builds its `<audio>` with jQuery and never inserts it into the
# document (gulp/js/views/transcript.js#loadAudio), so the only evidence of it is
# the network. Chrome's performance log records each request as it starts, which
# is what lets an *absent* request be asserted; resource timing only lists
# requests that have finished.
module EditorMediaRequests
  # Chrome's network-log type for a fetch an `<audio>`/`<video>` element issues.
  MEDIA_REQUEST_TYPE = 'Media'
  REQUEST_WILL_BE_SENT = 'Network.requestWillBeSent'
  # Media the page's own elements reference: the instructional videos the
  # project content renders into the instructions and conventions pages. The
  # editor's `<audio>` is never inserted into the document, so it is not listed.
  IN_DOCUMENT_MEDIA_URLS = <<~JS
    Array.prototype.slice.call(document.querySelectorAll('audio, video, audio source, video source'))
      .map(function(element) { return element.src; })
      .filter(function(url) { return !!url; })
  JS
  # A file this app serves (public/video), loaded the way `loadAudio` loads a
  # transcript's audio so its request marks the point the editor's would have
  # been logged by.
  MEDIA_MARKER_PATH = '/video/twl_sample.mp4'
  MEDIA_MARKER_SCRIPT = <<~JS
    jQuery('<audio preload><source src="' + arguments[0] + '" type="audio/mp4"></audio>');
  JS

  # Every media fetch the browser started for this page that none of the page's
  # own media elements accounts for — i.e. the editor's detached `<audio>`. It
  # needs a driver with Chrome's performance log (LocalChrome::NETWORK_DRIVER).
  #
  # Chrome logs a request when it starts, but the editor's audio request can
  # start after the render `visit_transcript` waits on, so an empty log right
  # after boot would prove nothing. A marker `<audio>` is loaded the same way
  # first, and the log is read until the marker's request appears: the editor's
  # audio began loading before the render, so its request would be logged by
  # then.
  def unaccounted_media_requests
    marker = "#{MEDIA_MARKER_PATH}?media-marker=#{SecureRandom.hex(8)}"
    page.execute_script(MEDIA_MARKER_SCRIPT, marker)
    requested = read_media_requests_until(marker)
    requested.reject { |url| url.end_with?(marker) } - page.evaluate_script(IN_DOCUMENT_MEDIA_URLS)
  end

  private

  # Reading the performance log clears it, so each poll's requests are kept.
  def read_media_requests_until(marker)
    requested = []
    page.document.synchronize do
      requested.concat(media_request_urls)
      next if requested.any? { |url| url.end_with?(marker) }

      raise Capybara::ExpectationNotMet, "the browser never requested the media marker #{marker}"
    end
    requested
  end

  def media_request_urls
    page.driver.browser.logs.get(:performance).filter_map do |entry|
      message = JSON.parse(entry.message)['message']
      next unless message['method'] == REQUEST_WILL_BE_SENT && message.dig('params', 'type') == MEDIA_REQUEST_TYPE

      message.dig('params', 'request', 'url')
    end
  end
end
