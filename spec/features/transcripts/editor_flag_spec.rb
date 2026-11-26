# frozen_string_literal: true

require 'rails_helper'

# Flagging goes through the flag modal (gulp/js/views/transcripts/_flag.js):
# the line's flag control loads the line's flags, the modal posts a new one to
# `/flags.json`, and the line's `flag_count` is what makes the editor show it as
# flagged again after a reload. Only completed lines render the flag control
# (gulp/templates/transcripts/transcript_line.ejs).
RSpec.feature 'Transcript editor flagging' do
  # The line controls are revealed once their line is selected and are hidden
  # below the desktop breakpoint; the driver opens a desktop-sized window
  # (LocalChrome::WINDOW_SIZE in spec/support/capybara.rb).

  let(:editor) { TranscriptEditorPage.new.visit_transcript(world.transcript) }
  # The world seeds the error flag types the modal offers; use the one that is
  # not first so the scenario proves the chosen option is the one submitted.
  let(:flag_type) { world.flag_types.last }
  let(:comment) { 'The surname is misspelled.' }
  let(:admin) { create(:user, :admin) }

  describe 'a completed line', :js do
    let(:world) { build_content_world(line_overrides: { 0 => { status: 'completed' } }) }

    # The row the line survives a reload on is only a count, so the stored flag is
    # read as well: it is what proves the modal submitted the option that was
    # chosen rather than the first one, and that the comment was sent at all.
    # rubocop:disable RSpec/ExampleLength
    scenario 'is shown as flagged after a visitor flags it', :aggregate_failures do
      expect(editor.line_flagged?(0)).to be(false)
      editor.flag_line(0, flag_type.label, comment: comment)
      expect(editor.flag_confirmation).to include('Thank you for flagging')

      flag = Flag.order(:id).last
      expect(flag.flag_type_id).to eq(flag_type.id)
      expect(flag.text).to eq(comment)

      editor.reload
      expect(editor.line_flagged?(0)).to be(true)
    end
    # rubocop:enable RSpec/ExampleLength

    scenario 'loses the flag when an admin resolves it', :aggregate_failures do
      sign_in admin
      editor.flag_line(0, flag_type.label).reload
      expect(editor.line_flagged?(0)).to be(true)
      editor.resolve_line(0).reload
      expect(editor.line_flagged?(0)).to be(false)
    end
  end

  describe 'a flagged line', :js do
    let(:world) { build_content_world(line_overrides: { 0 => { status: 'flagged' } }) }
    let(:flagged_text) { world.transcript_lines.first.original_text }

    # `flagged` is one of the statuses `is_editable` locks, so the field is not
    # contenteditable and the attempted edit never leaves the browser.
    scenario 'is read-only for an anonymous visitor', :aggregate_failures do
      expect(editor.line_editable?(0)).to be(false)
      editor.edit_line(0, 'This correction must not be stored.').reload
      expect(editor.line_text(0)).to eq(flagged_text)
    end
  end
end
