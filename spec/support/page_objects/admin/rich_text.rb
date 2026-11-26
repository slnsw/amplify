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
      raise Capybara::ExpectationNotMet, SYNC_MISSING unless stored_text(editable).include?(text_of(value))
    end
  end

  # AutoSync copies the editor's HTML, not its text, so the stored value differs
  # from what was typed in two ways: `&`, `<` and `>` arrive escaped (`&amp;`,
  # `&lt;`) and a line break arrives as `</p><p>` or `<br>`. Both sides are reduced
  # to their text. Tags are stripped before entities are unescaped, so a typed
  # `&lt;` is not mistaken for markup.
  def stored_text(editable)
    text_of(note_value(editable))
  end

  def text_of(value)
    value.to_s
         .gsub(%r{<br\s*/>?}i, "\n")
         .gsub(%r{</(?:p|div)>}i, "\n")
         .gsub(/<[^>]+>/, '')
         .then { |text| CGI.unescapeHTML(text) }
         .gsub(/\s+/, ' ')
         .strip
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
