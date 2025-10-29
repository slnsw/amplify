# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptSpeakerEditsController, type: :controller do
  describe '#create' do
    let!(:line) { create(:transcript_line) }
    let(:params) { { transcript_speaker_edit: { transcript_line_id: line.id, speaker_id: 1 } } }

    context 'when user is signed in and no existing edit' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculateSpeaker)
      end

      it 'creates a new speaker edit' do
        expect do
          post :create, params: params, as: :json
        end.to change(TranscriptSpeakerEdit, :count).by(1)
      end

      it 'responds created' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end

      it 'calls recalculateSpeaker on the line' do
        post :create, params: params, as: :json
        expect(line).to have_received(:recalculateSpeaker)
      end
    end

    context 'when an existing edit exists for the user' do
      let(:user) { create(:user) }

      before do
        create(:transcript_speaker_edit, user_id: user.id, transcript_line: line, speaker_id: 1)
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculateSpeaker)
      end

      it 'updates the existing speaker edit and returns no_content' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is not signed in but session exists' do
      let(:session_id) { 'sess-123' }

      before do
        create(:transcript_speaker_edit, session_id: session_id, transcript_line: line)
        session_obj = { id: session_id }
        def session_obj.id = self.[](:id)
        allow(controller).to receive(:session).and_return(session_obj)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculateSpeaker)
      end

      it 'updates existing session edit and returns no_content' do
        payload = { transcript_speaker_edit: { transcript_line_id: line.id, session_id: session_id, speaker_id: 1 } }
        post :create, params: payload, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is not signed in and no existing session edit' do
      let(:session_id) { 'sess-456' }

      before do
        session_obj = { id: session_id }
        def session_obj.id = self.[](:id)
        allow(controller).to receive(:session).and_return(session_obj)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculateSpeaker)
      end

      it 'creates a new session-based speaker edit' do
        payload = { transcript_speaker_edit: { transcript_line_id: line.id, session_id: session_id, speaker_id: 2 } }
        expect do
          post :create, params: payload, as: :json
        end.to change(TranscriptSpeakerEdit, :count).by(1)
      end

      it 'responds created for session-based create' do
        payload = { transcript_speaker_edit: { transcript_line_id: line.id, session_id: session_id, speaker_id: 2 } }
        post :create, params: payload, as: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'when create fails due to validation' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        bad = build(:transcript_speaker_edit)
        allow(TranscriptSpeakerEdit).to receive(:new).and_return(bad)
        allow(bad).to receive_messages(save: false, errors: {})
      end

      it 'responds with unprocessable_entity' do
        post :create, params: { transcript_speaker_edit: { transcript_line_id: line.id } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when update fails for existing edit' do
      let(:user) { create(:user) }

      before do
        existing = create(:transcript_speaker_edit, user_id: user.id, transcript_line: line, speaker_id: 1)
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(existing).to receive(:update).and_return(false)
        allow(TranscriptSpeakerEdit).to receive(:find_by).and_return(existing)
      end

      it 'responds with unprocessable_entity' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when transcript line not found' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          post :create, params: { transcript_speaker_edit: { transcript_line_id: 999_999, speaker_id: 1 } }, as: :json
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
