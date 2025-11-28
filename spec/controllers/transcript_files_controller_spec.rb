# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptFilesController, type: :controller do
  describe '#index' do
    let(:transcripts) { [build_stubbed(:transcript)] }

    before do
      allow(Transcript).to receive(:get_updated_after).and_return(transcripts)
      get :index, params: { updated_after: '2020-01-01' }, as: :json
    end

    it 'assigns @transcripts from the service' do
      expect(assigns(:transcripts)).to eq(transcripts)
    end

    it 'assigns @opt to permitted params' do
      expect(assigns(:opt)).to be_a(ActionController::Parameters)
    end

    it 'responds with json content type' do
      expect(response.content_type).to include 'application/json'
    end
  end

  describe '#show' do
    let(:transcript) { build_stubbed(:transcript, id: 1) }

    before do
      allow(Transcript).to receive(:find_by).with(uid: 'the-uid').and_return(transcript)
    end

    context 'when requested format is json and edits param present' do
      let(:statuses) { [] }
      let(:speakers) { [] }
      let(:edits) { [] }

      before do
        allow(TranscriptLineStatus).to receive(:allCached).and_return(statuses)
        allow(TranscriptSpeaker).to receive(:getByTranscriptId).with(transcript.id).and_return(speakers)
        allow(TranscriptEdit).to receive(:getByTranscript).with(transcript.id).and_return(edits)
        get :show, params: { id: 'the-uid', edits: 1 }, as: :json
      end

      it 'assigns transcript line statuses' do
        expect(assigns(:transcript_line_statuses)).to eq(statuses)
      end

      it 'assigns transcript speakers' do
        expect(assigns(:transcript_speakers)).to eq(speakers)
      end

      it 'assigns transcript edits' do
        expect(assigns(:transcript_edits)).to eq(edits)
      end
    end

    context 'when speakers option is requested (text/vtt)' do
      before do
        allow(TranscriptLine).to receive(:getByTranscriptWithSpeakers).with(transcript.id).and_return([])
        get :show, params: { id: 'the-uid', speakers: 1 }, format: :text
      end

      it 'assigns transcript_lines with speakers' do
        expect(assigns(:transcript_lines)).to be_an(Array)
      end
    end

    context 'when no special options provided (default text)' do
      before do
        allow(transcript).to receive(:transcript_lines).and_return([])
        get :show, params: { id: 'the-uid' }, format: :text
      end

      it 'assigns transcript_lines from transcript' do
        expect(assigns(:transcript_lines)).to eq([])
      end
    end
  end
end
