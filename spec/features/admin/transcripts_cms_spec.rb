# frozen_string_literal: true

require 'rails_helper'

# /admin/cms/collections/:uid is where an admin manages a collection's items, and
# /admin/cms/transcripts/:uid/edit is where an item's uploaded script is turned
# into transcript lines or reset again (app/controllers/admin/cms/transcripts_controller.rb).
RSpec.feature 'CMS transcripts' do
  let(:transcripts) { AdminCmsTranscriptsPage.new }
  let(:script) { Rails.root.join('spec/fixtures/transcript.srt') }
  let(:created_uid) { 'cms-created-item' }

  describe 'the item forms as an admin', :js do
    let(:world) { build_content_world }

    before do
      world
      sign_in_as(:admin)
    end

    scenario 'renders the new item form', :aggregate_failures do
      transcripts.visit_new(world.collection.uid)

      expect(page).to have_text('Create a new item')
      expect(page).to have_field('transcript_uid')
    end

    scenario 'renders the edit form of an existing item', :aggregate_failures do
      transcripts.visit_edit(world.transcript.uid)

      expect(page).to have_text('Edit an item')
      expect(page).to have_field('transcript_title', with: world.transcript.title)
    end

    scenario 'creates an item the collection list shows after a reload', :aggregate_failures do
      transcripts.create(uid: created_uid, title: 'Created item', collection_uid: world.collection.uid)

      expect(transcripts.item_titles).to include('Created item')
      page.refresh
      expect(transcripts.item_titles).to include('Created item')
    end
  end

  describe 'processing an uploaded script as an admin', :js do
    let(:world) { build_content_world(transcript: false) }

    before do
      world
      # `VoiceBase::ImportSrtTranscripts` stamps the item with this status, and
      # the NOT NULL column rejects the import when the row is missing.
      TranscriptStatus.find_by(name: 'transcript_downloaded') || TranscriptStatus.create!(name: 'transcript_downloaded')
      sign_in_as(:admin)
    end

    scenario 'reports the line count and stores the lines', :aggregate_failures do
      create_and_process(uid: created_uid, title: 'Processed item')

      transcripts.visit_edit(created_uid)
      expect(transcripts.line_count).to eq('1 line in database')
    end

    # `TranscriptService#reset` rewrites every line and zeroes the item's
    # counters rather than deleting the lines, so the completion totals the
    # summary page reports are what carry its effect.
    scenario 'resets the progress the summary page reports', :aggregate_failures do
      create_and_process(uid: created_uid, title: 'Reset item')
      Transcript.find_by!(uid: created_uid).update!(lines_completed: 1, percent_completed: 100)
      expect(completed_percentage).to eq('100.00 %')

      transcripts.visit_edit(created_uid).reset
      expect(completed_percentage).to eq('0.00 %')
    end
  end

  describe 'the bulk actions of a collection as an admin', :js do
    let(:world) { build_content_world(published: false, extra_transcripts: [{ title: 'Second item' }]) }

    before do
      world
      sign_in_as(:admin)
      transcripts.visit_collection(world.collection.uid)
    end

    scenario 'publishes every selected item', :aggregate_failures do
      expect(transcripts.unpublished?(world.transcript.title)).to be(true)

      transcripts.select_all_items.bulk_action('Publish')

      expect(transcripts.published?(world.transcript.title)).to be(true)
      expect(transcripts.published?('Second item')).to be(true)
    end

    # The bulk action re-renders the list from the server's response, so a
    # reload is what proves the publish was stored rather than echoed back.
    scenario 'keeps the selected items published after a reload' do
      transcripts.select_all_items.bulk_action('Publish')

      page.refresh
      expect(transcripts.published?('Second item')).to be(true)
    end
  end

  describe 'the speaker search as an admin' do
    let(:world) { build_content_world }

    before do
      world
      sign_in_as(:admin)
    end

    # The item form autocompletes speakers from this endpoint
    # (app/assets/javascripts/search_auto_complete.js); it has no page of its
    # own, so the JSON it answers with is read directly.
    scenario 'returns the speakers matching the query' do
      page.visit('/admin/cms/transcripts/speaker_search?query=speaker%202')

      expect(JSON.parse(page.body).fetch('suggestions')).to eq([{ 'value' => 'Speaker 2', 'data' => 'Speaker 2' }])
    end
  end

  private

  def create_and_process(uid:, title:)
    transcripts.create(uid: uid, title: title, collection_uid: world.collection.uid, script: script)
    transcripts.visit_edit(uid).process.await_line_count('1 lines in database')
  end

  def completed_percentage
    page.visit('/admin/summary')
    page.find('tr', text: 'Completed').find('td').text
  end
end
