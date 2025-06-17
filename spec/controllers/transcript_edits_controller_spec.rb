# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptEditsController, type: :controller do
  routes { Rails.application.routes }

  let(:user) { create(:user) }
  let(:transcript_line) { create(:transcript_line) }
  let(:transcript) { transcript_line.transcript }
  let(:project) { double }
  let(:edit) { create(:transcript_edit, transcript_line: transcript_line, transcript: transcript, user_id: user.id) }
  let(:valid_params) do
    {
      transcript_edit: {
        transcript_id: transcript.id,
        transcript_line_id: transcript_line.id,
        user_id: user.id,
        text: 'Edit text'
      }
    }
  end

  before do
    allow(controller).to receive(:authenticate_user).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:user_signed_in?).and_return(true)
    fake_session = double('session', id: 'session123')
    allow(fake_session).to receive(:[]=)
    allow(controller).to receive(:session).and_return(fake_session)
    allow(Project).to receive(:getActive).and_return(project)
    allow(transcript_line).to receive(:recalculate)
    allow(user).to receive(:incrementLinesEdited)
  end

  describe 'GET #index' do
    it 'returns edits for a transcript_line_id' do
      allow(TranscriptEdit).to receive(:getByLineForDisplay).and_return([edit])
      get :index, params: { transcript_line_id: transcript_line.id }, format: :json
      expect(assigns(:transcript_edits)).to eq([edit])
    end

    it 'returns edits and transcripts for a user_id' do
      allow(TranscriptEdit).to receive(:getByUser).and_return([edit])
      allow(Transcript).to receive(:getByUserEdited).and_return([transcript])
      get :index, params: { user_id: user.id }, format: :json
      expect(assigns(:transcript_edits)).to eq([edit])
      expect(assigns(:transcripts)).to eq([transcript])
    end

    it 'returns edits and transcripts for current_user if signed in' do
      allow(TranscriptEdit).to receive(:getByUser).and_return([edit])
      allow(Transcript).to receive(:getByUserEdited).and_return([transcript])
      get :index, format: :json
      expect(assigns(:transcript_edits)).to eq([edit])
      expect(assigns(:transcripts)).to eq([transcript])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested edit' do
      allow(TranscriptEdit).to receive(:find).and_return(edit)
      get :show, params: { id: edit.id }, format: :json
      expect(assigns(:transcript_edit)).to eq(edit)
    end
  end

  describe 'POST #create' do
    context 'when transcript_line does not exist' do
      it 'returns no_content' do
        allow(TranscriptLine).to receive(:find).and_return(nil)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when creating a new edit' do
      it 'creates and returns created' do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        allow(TranscriptEdit).to receive(:find_by).and_return(nil)
        t_edit = build_stubbed(:transcript_edit, transcript_line: transcript_line, transcript: transcript, user_id: user.id)
        allow(TranscriptEdit).to receive(:new).and_return(t_edit)
        allow(t_edit).to receive(:save).and_return(true)
        allow(transcript_line).to receive(:recalculate)
        allow(user).to receive(:incrementLinesEdited)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'when updating an existing edit' do
      it 'updates and returns no_content' do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        t_edit = build_stubbed(:transcript_edit, transcript_line: transcript_line, transcript: transcript, user_id: user.id)
        allow(TranscriptEdit).to receive(:find_by).and_return(t_edit)
        allow(t_edit).to receive(:update).and_return(true)
        allow(transcript_line).to receive(:recalculate)
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when creation fails' do
      it 'returns unprocessable_entity' do
        allow(TranscriptLine).to receive(:find).and_return(transcript_line)
        allow(TranscriptEdit).to receive(:find_by).and_return(nil)
        t_edit = build_stubbed(:transcript_edit, transcript_line: transcript_line, transcript: transcript, user_id: user.id)
        allow(TranscriptEdit).to receive(:new).and_return(t_edit)
        allow(t_edit).to receive(:save).and_return(false)
        allow(t_edit).to receive(:errors).and_return({ error: 'fail' })
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
