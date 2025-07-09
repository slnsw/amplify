require 'rails_helper'

RSpec.describe TranscriptSpeakerEditsController, type: :controller do
  routes { Rails.application.routes }

  let(:user) { create(:user) }
  let(:transcript_line) { create(:transcript_line) }
  let(:project) { double }
  let(:speaker) { create(:speaker) }
  let(:valid_params) do
    {
      transcript_speaker_edit: {
        transcript_id: transcript_line.transcript_id,
        transcript_line_id: transcript_line.id,
        speaker_id: speaker.id
      }
    }
  end

  before do
    allow(controller).to receive(:authenticate_user).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:user_signed_in?).and_return(true)
    fake_session = double("session", id: "session123")
    allow(fake_session).to receive(:[]=)
    allow(controller).to receive(:session).and_return(fake_session)
    allow(Project).to receive(:getActive).and_return(project)
  end

  describe "GET #index" do
    it "returns an empty array" do
      get :index, format: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET #show" do
    it "returns nil" do
      t_edit = create(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
      get :show, params: { id: t_edit.id }, format: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to be_nil
    end

    it "returns the transcript_speaker_edit as json" do
      t_edit = create(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
      get :show, params: { id: t_edit.id }, format: :json
      expect(response).to be_successful
      # Optionally, check the JSON body here
    end
  end

  describe "POST #create" do
    context "when transcript_line does not exist" do
      it "returns no_content" do
        allow(TranscriptLine).to receive(:find).and_return(nil)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when creating a new edit" do
      it "creates and returns created" do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        allow(TranscriptSpeakerEdit).to receive(:find_by).and_return(nil)
        t_edit = build_stubbed(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
        allow(TranscriptSpeakerEdit).to receive(:new).and_return(t_edit)
        allow(t_edit).to receive(:save).and_return(true)
        allow(transcript_line).to receive(:recalculateSpeaker)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
      end
    end

    context "when updating an existing edit" do
      it "updates and returns no_content" do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        t_edit = build_stubbed(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
        allow(TranscriptSpeakerEdit).to receive(:find_by).and_return(t_edit)
        allow(t_edit).to receive(:update).and_return(true)
        allow(transcript_line).to receive(:recalculateSpeaker)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when creation fails" do
      it "returns unprocessable_entity" do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        allow(TranscriptSpeakerEdit).to receive(:find_by).and_return(nil)
        t_edit = build_stubbed(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
        allow(TranscriptSpeakerEdit).to receive(:new).and_return(t_edit)
        allow(t_edit).to receive(:save).and_return(false)
        allow(t_edit).to receive(:errors).and_return({ error: "fail" })
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates and returns no_content" do
      t_edit = create(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
      allow(TranscriptSpeakerEdit).to receive(:find).and_return(t_edit)
      allow(t_edit).to receive(:update).and_return(true)
      patch :update, params: { id: t_edit.id, transcript_speaker_edit: { speaker_id: speaker.id } }, format: :json
      expect(response).to have_http_status(:no_content)
    end

    it "returns errors on failure" do
      t_edit = create(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
      allow(TranscriptSpeakerEdit).to receive(:find).and_return(t_edit)
      allow(t_edit).to receive(:update).and_return(false)
      allow(t_edit).to receive(:errors).and_return({ error: "fail" })
      patch :update, params: { id: t_edit.id, transcript_speaker_edit: { speaker_id: speaker.id } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE #destroy" do
    it "destroys and returns no_content" do
      t_edit = create(:transcript_speaker_edit, speaker_id: speaker.id, transcript_line_id: transcript_line.id)
      allow(TranscriptSpeakerEdit).to receive(:find).and_return(t_edit)
      expect(t_edit).to receive(:destroy)
      delete :destroy, params: { id: t_edit.id }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end