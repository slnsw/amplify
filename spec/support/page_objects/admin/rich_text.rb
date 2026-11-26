# frozen_string_literal: true

require 'cgi'

# Shared by the admin page objects whose forms render a field through Summernote
# (app/assets/javascripts/editor.js initialises every `[data-provider="summernote"]`).
# Summernote replaces the textarea with a contenteditable and copies it back on
# each `summernote.change` (its AutoSync plugin), so the editor has to be typed
# into: filling the hidden textarea would be overwritten before the form posts.
#
# Including page objects only need the private `page` method they all define.
module AdminRichText
  EDITABLE = '.note-editable'
  NOTE_TEXTAREA = 'textarea'
  SYNC_MISSING = 'Summernote has not copied the editor back into its textarea'

  def type_into_editor(value, editable: EDITABLE)
    editor = page.find(editable)
    editor.click
    editor.send_keys(value)
    wait_for_note_sync(value, editable)
    editor
  end

  private

  # The change events AutoSync listens to trail the last keystroke, so the
  # textarea the form submits can still be missing the end of the text.
  def wait_for_note_sync(value, editable)
    page.document.synchronize do
      raise Capybara::ExpectationNotMet, SYNC_MISSING unless stored_text(editable).include?(value)
    end
  end

  # AutoSync copies the editor's HTML, not its text, so a value containing `&`,
  # `<` or `>` reaches the textarea escaped (`&amp;`, `&lt;`). Comparing the raw
  # value would wait out the timeout on text that synced correctly.
  def stored_text(editable)
    CGI.unescapeHTML(note_value(editable))
  end

  def note_value(editable)
    page.evaluate_script(<<~JS)
      (function () {
        var editor = document.querySelector('#{editable}')
        var box = editor && editor.closest('.form-group')
        var note = box && box.querySelector('#{NOTE_TEXTAREA}')
        return note ? note.value : ''
      })()
    JS
  end
end
