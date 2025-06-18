require "rails_helper"

RSpec.describe TranscriptFilesController, type: :controller do
  let(:transcript) { create(:transcript, uid: "the-uid") }

  describe "GET #index" do
    it "returns transcripts updated after a date (GET /transcripts.json?updated_after=yyyy-mm-dd&page=1)" do
      allow(Transcript).to receive(:getUpdatedAfter).and_return([transcript])
      get :index, params: { updated_after: "2020-01-01", page: 1 }, format: :json
      expect(assigns(:transcripts)).to eq([transcript])
      expect(assigns(:opt)).to eq(ActionController::Parameters.new.permit!) # or just expect(assigns(:opt)).to eq({})
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    before do
      allow(Transcript).to receive(:find_by).with(uid: "the-uid").and_return(transcript)
      allow(Project).to receive(:getActive).and_return(double)
      allow(TranscriptLineStatus).to receive(:allCached).and_return([])
      allow(TranscriptSpeaker).to receive(:getByTranscriptId).and_return([])
      allow(TranscriptEdit).to receive(:getByTranscript).and_return([])
      allow(transcript).to receive(:transcript_lines).and_return([])
      allow(TranscriptLine).to receive(:getByTranscriptWithSpeakers).and_return([])
    end

    it "renders JSON format with edits (GET /transcript_files/the-uid.json?edits=1)" do
      get :show, params: { id: "the-uid", format: :json, edits: 1 }
      expect(assigns(:transcript_line_statuses)).to eq([])
      expect(assigns(:transcript_speakers)).to eq([])
      expect(assigns(:transcript_edits)).to eq([])
      expect(response).to be_successful
    end

    it "renders with speakers option (GET /transcript_files/the-uid.text?speakers=1)" do
      get :show, params: { id: "the-uid", format: :text, speakers: 1 }
      expect(assigns(:transcript_lines)).to eq([])
      expect(response).to be_successful
    end

    it "renders with default transcript lines (GET /transcript_files/the-uid.text)" do
      get :show, params: { id: "the-uid", format: :text }
      expect(assigns(:transcript_lines)).to eq([])
      expect(response).to be_successful
    end
  end
end
