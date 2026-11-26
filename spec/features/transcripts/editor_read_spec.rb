# frozen_string_literal: true

require 'rails_helper'

# The transcript editor is client-rendered: `app/views/transcripts/show.html.erb`
# ships an empty `#main`, and the Backbone view builds the whole transcript from
# the `...show.json` payload. These specs therefore assert on what the browser
# ends up showing, not on the server response.
RSpec.feature 'Transcript editor' do
  describe 'reading a published transcript', :js do
    let(:world) { build_content_world }
    let(:editor) { TranscriptEditorPage.new.visit_transcript(world.transcript) }
    let(:instructions_text) { ContentWorld::INSTRUCTIONS_CONTENT.delete_prefix('<p>').delete_suffix('</p>') }
    let(:first_convention) { world.transcription_conventions.first.convention_key }

    scenario 'renders one row per transcript line with its text', :aggregate_failures, :smoke do
      expect(editor.line_count).to eq(world.transcript_lines.size)
      expect(editor.line_texts).to eq(world.transcript_lines.map(&:original_text))
      expect(page).to have_text(world.transcript.title)
    end

    scenario 'lists the participants and offers a speaker control', :aggregate_failures do
      expect(editor.speaker_names).to eq(world.speakers.map(&:name))
      expect(page).to have_css(TranscriptEditorPage::SPEAKER_CONTROL, count: world.transcript_lines.size)
    end

    scenario 'renders the instructions page and the transcription conventions', :aggregate_failures do
      editor
      # The instructions block is `visibility: hidden` below the desktop breakpoint
      # (components/editor/_show.scss); the driver opens a desktop-sized window.

      expect(page.find(TranscriptEditorPage::INSTRUCTIONS, visible: :all)).to have_text(instructions_text)
      expect(page.find(TranscriptEditorPage::CONVENTIONS, visible: :all).text(:all)).to include(first_convention)
    end
  end

  describe 'playback', :js do
    let(:audio_source) { '/video/twl_sample.mp4' }

    scenario 'loads the audio source the editor is given' do
      world = build_content_world(transcript_attributes: { vendor_audio_urls: [audio_source] })
      expect(TranscriptEditorPage.new.visit_transcript(world.transcript).has_audio?).to be(true)
    end

    # Asserted from Chrome's network log rather than from `has_audio?`, which
    # looks for the sources the model reports and so depends on how
    # `vendor_audio_urls` happens to read back (known defect 7): this fails if the
    # editor fetches any media the page itself does not render.
    scenario 'requests no audio for a transcript without an audio source', driver: LocalChrome::NETWORK_DRIVER do
      world = build_content_world
      expect(TranscriptEditorPage.new.visit_transcript(world.transcript).unaccounted_media_requests).to be_empty
    end
  end

  describe 'previewing an unpublished transcript', :js do
    let(:world) { build_content_world(published: false, collection_published: true) }
    # This is the link the CMS offers; the controller redirects it to the
    # institution/collection editor route, keeping the preview flag.
    let(:preview_path) { "/transcripts/#{world.transcript.uid}?preview=true" }
    let(:editor_path) do
      "/transcripts/#{world.institution.slug}/#{world.collection.uid}/#{world.transcript.uid}?preview=true"
    end

    before do
      sign_in signed_in_user
      page.visit(preview_path)
      wait_for_editor_boot
    end

    context 'when an admin' do
      let(:signed_in_user) { create(:user, :admin) }

      scenario 'opens the editor and marks it as a preview', :aggregate_failures do
        expect(page).to have_current_path(editor_path)
        expect(page).to have_css(TranscriptEditorPage::PREVIEW_TAG, text: '[Preview]')
        expect(page.all(TranscriptEditorPage::LINES).size).to eq(world.transcript_lines.size)
      end
    end

    context 'when a content editor' do
      let(:signed_in_user) { create(:user, :content_editor) }

      scenario 'opens the editor and marks it as a preview', :aggregate_failures do
        expect(page).to have_current_path(editor_path)
        expect(page).to have_css(TranscriptEditorPage::PREVIEW_TAG, text: '[Preview]')
        expect(page.all(TranscriptEditorPage::LINES).size).to eq(world.transcript_lines.size)
      end
    end
  end

  # Deliberately not `:js`: an unpublished transcript makes the editor throw
  # before it renders anything, and the suite's console check would report that
  # crash as a failure rather than the leak this guards against.
  describe 'an unpublished transcript' do
    let(:world) { build_content_world(published: false) }
    let(:editor_path) { "/transcripts/#{world.institution.slug}/#{world.collection.uid}/#{world.transcript.uid}" }

    scenario 'is not exposed to an anonymous visitor by the editor page' do
      visit editor_path
      # `show.html.erb` writes the transcript title into the og: metatags, so
      # this fails the moment the lookup stops filtering unpublished records.
      expect(page.body).not_to include(world.transcript.title)
    end

    scenario 'is not served to an anonymous visitor by the editor payload' do
      visit "#{editor_path}.json"
      payload = JSON.parse(page.body)
      expect(payload).to include('id' => nil, 'title' => nil, 'lines' => [])
    end
  end
end
