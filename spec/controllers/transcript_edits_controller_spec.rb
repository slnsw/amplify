# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptEditsController, type: :controller do
  describe '#index' do
    context 'when transcript_line_id is provided' do
      let(:edits) { [build_stubbed(:transcript_edit)] }

      before do
        allow(TranscriptEdit).to receive(:getByLineForDisplay).with('1').and_return(edits)
        get :index, params: { transcript_line_id: 1 }, as: :json
      end

      it 'assigns @transcript_edits from the service' do
        expect(assigns(:transcript_edits)).to eq(edits)
      end

      it 'responds with json content type' do
        expect(response.content_type).to include 'application/json'
      end
    end

    context 'when user_id is provided' do
      let(:edits) { [build_stubbed(:transcript_edit)] }
      let(:transcripts) { [build_stubbed(:transcript)] }

      before do
        allow(TranscriptEdit).to receive(:getByUser).with('2').and_return(edits)
        allow(Transcript).to receive(:get_by_user_edited).with('2').and_return(transcripts)
        get :index, params: { user_id: 2 }, as: :json
      end

      it 'assigns @transcript_edits from TranscriptEdit.getByUser' do
        expect(assigns(:transcript_edits)).to eq(edits)
      end

      it 'assigns @transcripts with transcripts edited by user' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }
      let(:edits) { [build_stubbed(:transcript_edit)] }
      let(:transcripts) { [build_stubbed(:transcript)] }

      before do
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptEdit).to receive(:getByUser).with(user.id).and_return(edits)
        allow(Transcript).to receive(:get_by_user_edited).with(user.id).and_return(transcripts)
        get :index, as: :json
      end

      it 'assigns @transcript_edits for the current user' do
        expect(assigns(:transcript_edits)).to eq(edits)
      end

      it 'assigns @transcripts for the current user' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end
    end
  end

  describe '#show' do
    let!(:edit) { create(:transcript_edit) }

    before { get :show, params: { id: edit.id }, as: :json }

    it 'assigns @transcript_edit' do
      expect(assigns(:transcript_edit)).to eq(edit)
    end

    it 'responds with json content type' do
      expect(response.content_type).to include 'application/json'
    end
  end

  describe '#create' do
    let!(:line) { create(:transcript_line) }
    let(:params) { { transcript_edit: { transcript_line_id: line.id, text: 'edited text' } } }

    context 'when user is signed in and no existing edit' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculate)
        allow(user).to receive(:incrementLinesEdited)
      end

      it 'calls recalculate on the transcript line' do
        post :create, params: params, as: :json
        expect(line).to have_received(:recalculate)
      end

      it 'creates a new transcript edit' do
        expect do
          post :create, params: params, as: :json
        end.to change(TranscriptEdit, :count).by(1)
      end

      it 'increments current_user lines edited' do
        post :create, params: params, as: :json
        expect(user).to have_received(:incrementLinesEdited)
      end

      it 'responds with created status' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
    end

    context 'when an existing edit exists for the user' do
      let(:user) { create(:user) }

      before do
        create(:transcript_edit, user_id: user.id, transcript_line: line, text: 'old')

        allow(controller).to receive_messages(user_signed_in?: true, current_user: user)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculate)
      end

      it 'calls recalculate on the transcript line' do
        post :create, params: params, as: :json
        expect(line).to have_received(:recalculate)
      end

      it 'returns no_content' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is not signed in but session exists' do
      let(:session_id) { 'sess-123' }
      let(:session_payload) do
        { transcript_edit: { transcript_line_id: line.id, session_id: session_id, text: 'edited text' } }
      end

      before do
        create(:transcript_edit, session_id: session_id, transcript_line: line)

        # stub controller.session with a real Hash that responds to id and supports [] assignment
        sess = { id: session_id }
        def sess.id = self.[](:id)
        allow(controller).to receive(:session).and_return(sess)
        allow(TranscriptLine).to receive(:find).and_return(line)
        allow(line).to receive(:recalculate)
      end

      it 'calls recalculate on the transcript line for session edits' do
        post :create, params: session_payload, as: :json
        expect(line).to have_received(:recalculate)
      end

      it 'returns no_content for session edit update' do
        post :create, params: session_payload, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
