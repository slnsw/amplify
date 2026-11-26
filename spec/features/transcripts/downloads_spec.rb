# frozen_string_literal: true

require 'rails_helper'

# `TranscriptFilesController#show` serves the same transcript as plain text
# (show.text.erb), WebVTT (show.vtt.erb) or JSON (show.json.jbuilder), so these
# bodies are not documents: Capybara's text matchers would parse them and report
# nothing, and assertions read `page.body` instead.
RSpec.feature 'Transcript downloads' do
  let(:world) { build_content_world }
  let(:transcript) { world.transcript }
  let(:downloads_path) { "/transcript_files/#{transcript.uid}" }

  describe 'plain text format', :aggregate_failures do
    scenario 'writes each line with its timestamp and speaker' do
      visit "#{downloads_path}.text?timestamps=1&speakers=1"

      expect(page.body).to include(transcript.title)
      # build_content_world gives line n a start_time of n * 5s and round-robins
      # the speakers, so line 2 is the second speaker at 00:00:05.000.
      expect(page.body).to include('00:00:05.000 <Speaker 2> Transcript line 2 original text.')
    end

    scenario 'omits timestamps and speakers when they are not requested' do
      visit "#{downloads_path}.text"

      expect(page.body).to include('Transcript line 2 original text.')
      expect(page.body).not_to include('00:00:05.000')
      expect(page.body).not_to include('<Speaker 2>')
    end
  end

  describe 'WebVTT format', :aggregate_failures do
    scenario 'writes a WEBVTT document whose cues carry their timing' do
      visit "#{downloads_path}.vtt?speakers=1"

      expect(page.body).to start_with("WEBVTT\n\n")
      # Line n ends 4s after it starts (ContentWorld#build_transcript_line).
      expect(page.body).to include(
        "00:00:05.000 --> 00:00:09.000\n<v Speaker 2> Transcript line 2 original text."
      )
    end
  end

  describe 'JSON format', :aggregate_failures do
    let(:payload) { JSON.parse(page.body) }
    let(:statuses) { payload['statuses'].index_by { |status| status['id'] } }
    # Lines reference a status by id and the payload carries the status table the
    # client resolves those ids against.
    let(:line_status_names) { payload['lines'].map { |line| statuses.dig(line['transcript_line_status_id'], 'name') } }

    before do
      create(
        :transcript_edit,
        transcript: transcript,
        transcript_line: world.transcript_lines.first,
        text: 'Corrected line text',
        session_id: 'download-spec-session'
      )
    end

    scenario 'returns one entry per transcript line' do
      visit "#{downloads_path}.json"

      expect(payload['lines'].map { |line| line['original_text'] })
        .to match_array(world.transcript_lines.map(&:original_text))
    end

    scenario 'returns the status each line points at and the speakers' do
      visit "#{downloads_path}.json"

      expect(line_status_names.uniq).to eq(['untranscribed'])
      expect(payload['speakers'].map { |speaker| speaker['name'] }).to eq(world.speakers.map(&:name))
    end

    scenario 'includes the edits only when they are requested' do
      visit "#{downloads_path}.json?edits=1"
      expect(payload['edits'].map { |edit| edit['text'] }).to eq(['Corrected line text'])

      visit "#{downloads_path}.json"
      expect(JSON.parse(page.body)).not_to have_key('edits')
    end
  end

  describe 'download modal', :js do
    let(:editor) { TranscriptEditorPage.new.visit_transcript(transcript) }
    let(:base_url) { "/transcript_files/#{transcript.uid}" }

    # The modal builds its URL from the chosen format radio and the checked
    # options of that format (gulp/js/views/transcripts/_download.js#updateURL).
    scenario 'builds the download URL for each selected format', :aggregate_failures do
      expect(editor.download_url_for('text')).to end_with("#{base_url}.text?timestamps=1&speakers=1")
      expect(editor.download_url_for('vtt')).to end_with("#{base_url}.vtt?speakers=1")
      expect(editor.download_url_for('json')).to end_with("#{base_url}.json")
    end
  end

  describe 'JSON index', :aggregate_failures do
    let(:stale_title) { 'Transcript last updated two days ago' }
    let(:fresh_title) { 'Transcript updated just now' }
    let(:world) do
      built = build_content_world(
        transcript_attributes: { title: stale_title },
        extra_transcripts: [{ title: fresh_title }]
      )
      built.transcript.update!(updated_at: 2.days.ago)
      built
    end
    let(:fresh_uid) { world.transcripts.last.uid }
    let(:entries) { JSON.parse(page.body)['entries'] }
    let(:titles) { entries.map { |entry| entry['title'] } }
    let(:fresh_entry) { entries.find { |entry| entry['title'] == fresh_title } }
    let(:expected_files) do
      {
        'json' => a_string_ending_with("/transcript_files/#{fresh_uid}.json"),
        'vtt' => a_string_ending_with("/transcript_files/#{fresh_uid}.vtt"),
        'text' => a_string_ending_with("/transcript_files/#{fresh_uid}.text")
      }
    end

    # The world is built lazily, so it has to exist before the request runs.
    before { world }

    scenario 'lists every transcript when no update filter is given' do
      visit '/transcript_files.json'

      expect(titles).to contain_exactly(stale_title, fresh_title)
    end

    scenario 'filters transcripts by update date' do
      visit "/transcript_files.json?updated_after=#{1.day.ago.to_date.iso8601}"

      expect(titles).to eq([fresh_title])
    end

    scenario 'lists each transcript with the URL of every download format' do
      visit '/transcript_files.json'

      expect(fresh_entry['files']).to include(expected_files)
    end
  end
end
