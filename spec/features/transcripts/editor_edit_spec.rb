# frozen_string_literal: true

require 'rails_helper'

# The editor saves when the user leaves a line, not on blur: selecting another
# line calls `onLineOff`, which runs `lineSave` (gulp/js/views/transcript.js).
# Each scenario therefore types into the real contenteditable field, selects
# another line to flush the edit, and reloads so the assertion reads back what
# the API persisted rather than what the page still holds in memory.
RSpec.feature 'Transcript editor editing' do
  # The text field is desktop-only and `lineSave` returns early below 768px
  # (gulp/js/views/transcripts/edit.js); the driver opens a desktop-sized window
  # (LocalChrome::WINDOW_SIZE in spec/support/capybara.rb).

  let(:editor) { TranscriptEditorPage.new.visit_transcript(world.transcript) }
  let(:first_text) { 'The first correction from this visitor.' }
  let(:edited_text) { 'The second correction from this visitor.' }
  let(:admin) { create(:user, :admin) }

  describe 'editing a line', :js do
    let(:world) { build_content_world }
    let(:user) { create(:user) }

    # The visitor's stored edits for the first line, read from the payload the
    # editor itself renders (`...show.json`) instead of from the database.
    let(:stored_line_edits) do
      editor.transcript_payload['user_edits']
            .select { |edit| edit['transcript_line_id'] == world.transcript_lines.first.id }
            .map { |edit| edit['text'] }
    end

    scenario 'keeps an anonymous visitor edit after a reload' do
      editor.edit_line(0, edited_text).reload
      expect(editor.line_text(0)).to eq(edited_text)
    end

    scenario 'lists a signed-in user edit on the dashboard' do
      sign_in user
      editor.edit_line(0, edited_text)
      page.visit '/dashboard'
      expect(page).to have_text(edited_text)
    end

    scenario 'updates the existing edit instead of recording a second one' do
      editor.edit_line(0, first_text).edit_line(0, edited_text)
      expect(stored_line_edits).to eq([edited_text])
    end
  end

  describe 'a completed line', :js do
    let(:world) { build_content_world(line_overrides: { 0 => { status: 'completed' } }) }
    let(:completed_text) { world.transcript_lines.first.text }

    # `is_editable` locks completed lines for everyone below the super user
    # hierarchy, so the field renders without `contenteditable` and typing does
    # not reach the line.
    scenario 'is read-only for an anonymous visitor', :aggregate_failures do
      expect(editor.line_editable?(0)).to be(false)
      editor.edit_line(0, edited_text).reload
      expect(editor.line_text(0)).to eq(completed_text)
    end

    scenario 'is editable for an admin' do
      sign_in admin
      editor.edit_line(0, edited_text).reload
      expect(editor.line_text(0)).to eq(edited_text)
    end
  end

  describe 'speaker selection', :js do
    let(:world) { build_content_world }
    let(:other_speaker) { world.speakers.last }

    scenario 'keeps the chosen speaker after a reload', :aggregate_failures do
      expect(editor.selected_speaker(0)).to eq(world.speakers.first.name)
      editor.select_speaker(0, other_speaker.name).reload
      expect(editor.selected_speaker(0)).to eq(other_speaker.name)
    end
  end

  describe 'resolving a flag', :js do
    let(:world) { build_content_world(line_overrides: { 0 => { status: 'completed', flagged: true } }) }

    # `POST /transcript_lines/:id/resolve`, driven through the resolve control the
    # editor renders for super users on lines that carry flags
    # (gulp/templates/transcripts/transcript_line.ejs).
    scenario 'marks the line resolved for an admin', :aggregate_failures do
      sign_in admin
      expect(editor.line_resolvable?(0)).to be(true)
      editor.resolve_line(0).reload
      expect(editor.line_resolvable?(0)).to be(false)
      expect(editor.line_flagged?(0)).to be(false)
    end
  end

  describe 'verifying a submitted edit', :js do
    let(:world) { build_content_world(line_overrides: { 0 => { status: 'reviewing' } }) }
    let(:submitted_texts) { ['First submitted transcription.', 'Second submitted transcription.'] }

    before do
      submitted_texts.each_with_index do |text, index|
        create(:transcript_edit, transcript: world.transcript, transcript_line: world.transcript_lines.first,
                                 text: text, user_id: 100 + index)
      end
    end

    scenario 'records the verified edit for an admin', :aggregate_failures do
      sign_in admin
      expect(editor.line_text(0)).to eq(world.transcript_lines.first.original_text)
      editor.verify_line(0, submitted_texts.last).reload
      expect(editor.line_text(0)).to eq(submitted_texts.last)
    end
  end
end
