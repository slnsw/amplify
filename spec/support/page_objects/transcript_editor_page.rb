# frozen_string_literal: true

require_relative '../features/editor_flagging'
require_relative '../features/waits'
require_relative 'editor_media_requests'
require 'rbconfig'

# Selectors and navigation for the transcript editor at
# `/transcripts/:institution_slug/:collection_uid/:transcript_uid`.
#
# The editor is client-rendered (app/views/transcripts/show.html.erb ships an
# empty `#main`), so `visit_transcript` waits for the first rendered line before
# returning. Selectors come from gulp/templates/transcripts/transcript_edit.ejs
# and transcript_line.ejs.
#
# It deliberately has no assertions and no Rails/factory/DB dependency, so the
# remote staging layer (spec/staging) can drive the same object against a real
# host: the transcript it is handed only has to expose `uid`, `collection.uid`,
# `collection.institution.slug` and the audio sources the editor loads.
class TranscriptEditorPage
  include EditorFlagging

  include ListTexts

  include Waits
  include EditorMediaRequests

  LINES = '#transcript-lines .line'
  # Each line renders a desktop and a mobile copy of its text and CSS shows one,
  # so the shared wrapper carries whichever copy is displayed.
  LINE_TEXT = "#{LINES} .text".freeze
  # The header paragraph joining every participant name; only rendered when the
  # transcript has speakers.
  PARTICIPANTS = '.speakers'
  PARTICIPANTS_PREFIX = 'Participants:'
  # Per-line speaker control, rendered only when the transcript has more than
  # one speaker (gulp/js/views/transcript.js#parseTranscript sets `has_speakers`).
  SPEAKER_CONTROL = "#{LINES} .speaker .change-speaker".freeze
  # transcript_edit.ejs emits this literal class for the instructions block.
  INSTRUCTIONS = '.transcript_edit\.md'
  CONVENTIONS = '#conventions-page'
  DOWNLOAD_URL = '#transcript-download-url'
  PREVIEW_TAG = '.preview-tag'

  # The rest of the selectors are relative to a `.line` row: `line(index)` scopes
  # them to one transcript line.
  #
  # The desktop copy of a line's text, a `contenteditable` span while the line is
  # editable and a plain span when `is_editable` (gulp/js/views/transcript.js)
  # locks it.
  TEXT_INPUT = '.text-input.desktop-only'
  # Per-line controls; the flag control only renders on completed lines and the
  # resolve control on completed lines the visitor may resolve that carry flags.
  RESOLVE_BUTTON = '.button.resolve'
  VERIFY_BUTTON = '.button.verify'
  SPEAKER = '.speaker'
  SPEAKER_OPTION = '.speaker-option'
  # The flag modal (gulp/js/views/transcripts/_flag.js); the modal wrapper gains
  # `active` on the `.modal` its template renders, not on the wrapper itself.
  # The verify modal (gulp/js/views/transcripts/_verify.js) lists the submitted
  # edits of a line in review.
  VERIFY_MODAL = '#transcript-line-verify .modal.active'
  VERIFY_OPTION = "#{VERIFY_MODAL} .option".freeze
  VERIFY_SUBMIT = "#{VERIFY_MODAL} .submit".freeze

  # Chrome maps select-all to the platform's modifier; the field's whole text is
  # replaced rather than appended to, so specs can name the expected text.
  SELECT_ALL_MODIFIER = RbConfig::CONFIG['host_os'].match?(/darwin/i) ? :meta : :control

  AUDIO_RESOURCE_URLS = <<~JS
    performance.getEntriesByType('resource')
      .filter(function(entry) { return entry.initiatorType === 'audio'; })
      .map(function(entry) { return entry.name; })
  JS
  def visit_transcript(transcript)
    @transcript = transcript
    page.visit(editor_path(transcript))
    wait_for_editor_boot
    self
  end

  def line_texts = texts_for(LINE_TEXT)

  def line_count
    page.all(LINES).size
  end

  # The editor creates its `<audio>` element with jQuery and never inserts it
  # into the document (gulp/js/views/transcript.js#loadAudio), so there is no
  # element to look for; what is observable, locally and against a real host, is
  # the media request it issues for the transcript's audio sources. Poll, because
  # that request starts with the render `wait_for_editor_boot` waits on and can
  # finish after it.
  def has_audio?
    sources = audio_sources
    return false if sources.empty?

    page.document.synchronize do
      next if audio_requested?(sources)

      raise Capybara::ElementNotFound, "the editor requested no audio for #{sources.join(', ')}"
    end
    true
  rescue Capybara::ElementNotFound
    false
  end

  # The download modal is parked off-canvas (components/editor/_modal.scss), so
  # its radios cannot be clicked; drive the change handler a click would fire and
  # read back the URL the view builds.
  def download_url_for(format)
    page.execute_script(<<~JS)
      var radio = document.querySelector('#format-#{format}');
      radio.checked = true;
      jQuery(radio).trigger('change');
    JS
    page.find(DOWNLOAD_URL, visible: :all).value
  end

  def speaker_names
    node = page.all(PARTICIPANTS).first
    return [] if node.nil?

    node.text.delete_prefix(PARTICIPANTS_PREFIX).split(',').map(&:strip)
  end

  # Reloading is how persistence is asserted: the editor rebuilds itself from the
  # `...show.json` payload, which the controller scopes to the visitor's session or
  # user, so what comes back is what the API stored.
  def reload
    page.refresh
    wait_for_editor_boot
    self
  end

  # The payload the editor renders from (`...show.json`), read over the visitor's
  # own session so specs can assert what persisted without reading the database.
  # Call it after visiting: it uses the page's jQuery, and `page.body` cannot be
  # parsed because the browser wraps a JSON document in a `<pre>`.
  def transcript_payload
    page.evaluate_async_script(<<~JS)
      var done = arguments[arguments.length - 1];
      jQuery.getJSON('#{editor_path(@transcript)}.json', function(payload) { done(payload); });
    JS
  end

  def line_text(index) = line(index).find('.text').text

  # Whether the editor left the line's field contenteditable, i.e. whether
  # `is_editable` allows this visitor to type into it.
  def line_editable?(index) = !field(index)['contenteditable'].nil?

  # Types `text` over the line's current text, then presses Enter, which the
  # editor maps to "next line": leaving a line runs `onLineOff` -> `lineSave`
  # (gulp/js/views/transcript.js), which is the only thing that submits an edit.
  def edit_line(index, text)
    wait_for_scroll_to_finish
    field(index).click
    page.send_keys(SELECT_ALL_MODIFIER, 'a')
    page.send_keys(text, :enter)
    wait_for_ajax_settle
    self
  end

  # The options only open on hover of a selected line's speaker column
  # (`.line.active .speaker:hover .speaker-options` in
  # app/assets/stylesheets/components/editor/_lines.scss), so select the line
  # first, as a user would by clicking it.
  def select_speaker(index, name)
    wait_for_scroll_to_finish
    row = line(index)
    row.click
    wait_for_scroll_to_finish
    row.find(SPEAKER).hover.find(SPEAKER_OPTION, text: name, exact_text: true).click
    wait_for_ajax_settle
    self
  end

  # The chosen speaker, read from the option the template marks as selected.
  # `visible: :all` because the options are hidden until the speaker is hovered.
  def selected_speaker(index) = line(index).all("#{SPEAKER_OPTION}.selected", visible: :all).first&.text(:all)

  def line_resolvable?(index) = line(index).all(RESOLVE_BUTTON, visible: :all).any?

  def resolve_line(index) = click_line_button(index, RESOLVE_BUTTON)

  # Chooses the submitted edit matching `text` in the verify modal and submits it.
  def verify_line(index, text)
    click_line_button(index, VERIFY_BUTTON)
    page.find(VERIFY_OPTION, exact_text: text).click
    page.find(VERIFY_SUBMIT).click
    wait_for_ajax_settle
    self
  end

  private

  def page
    Capybara.current_session
  end

  def line(index) = page.find("#{LINES}[sequence='#{index}']")

  def field(index) = line(index).find(TEXT_INPUT)

  # The per-line buttons are `visibility: hidden` until their line is hovered or
  # active (components/editor/_lines.scss), and the fixed player bar swallows a
  # hover at the line's centre, so select the line the way a user does before
  # clicking its control.
  def click_line_button(index, selector)
    wait_for_scroll_to_finish
    row = line(index)
    row.click
    wait_for_scroll_to_finish
    row.find(selector).click
    wait_for_ajax_settle
    self
  end

  def editor_path(transcript)
    collection = transcript.collection
    "/transcripts/#{collection.institution.slug}/#{collection.uid}/#{transcript.uid}"
  end

  # `Transcript#audio_url` is CarrierWave's mounted-uploader reader, which
  # shadows the same-named column and is nil without an uploaded file; vendor
  # audio arrives in `vendor_audio_urls`.
  def audio_sources
    sources = []
    sources.concat(Array(@transcript.vendor_audio_urls)) if @transcript.respond_to?(:vendor_audio_urls)
    sources << @transcript.audio_url if @transcript.respond_to?(:audio_url)
    sources.compact.reject(&:empty?)
  end

  # Sources are stored absolute (vendor CDN) or root-relative, while resource
  # timing always reports the resolved URL.
  def audio_requested?(sources)
    audio_resource_urls.any? do |url|
      sources.any? { |source| url.end_with?(source) }
    end
  end

  def audio_resource_urls
    page.evaluate_script(AUDIO_RESOURCE_URLS)
  end
end
