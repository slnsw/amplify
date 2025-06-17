# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlagsController, type: :controller do
  let(:user) { create(:user) }
  let(:transcript) { create(:transcript) }
  let(:transcript_line) { create(:transcript_line, transcript: transcript) }
  let(:flag_type) { create(:flag_type) }
  let!(:flag) { create(:flag, transcript_line: transcript_line, flag_type: flag_type, user_id: user.id) }

  before do
    allow(controller).to receive(:authenticate_user).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:user_signed_in?).and_return(true)
    # Use a double that responds to .id and []=
    fake_session = double('session', id: 'session123')
    allow(fake_session).to receive(:[]=)
    allow(controller).to receive(:session).and_return(fake_session)
  end

  describe 'GET #index' do
    it 'returns all flags' do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns flags for a transcript_line_id' do
      allow(Flag).to receive(:getByLine).with(transcript_line.id.to_s).and_return([flag])
      get :index, params: { transcript_line_id: transcript_line.id }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'returns the flag' do
      get :show, params: { id: flag.id }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    context 'when creating a new flag' do
      it 'creates a flag and returns no_content' do
        post :create, params: {
          flag: {
            transcript_id: transcript.id,
            transcript_line_id: transcript_line.id,
            flag_type_id: flag_type.id,
            text: 'Test flag'
          }
        }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when updating an existing flag' do
      it 'updates the flag and returns no_content' do
        post :create, params: {
          flag: {
            transcript_id: transcript.id,
            transcript_line_id: transcript_line.id,
            flag_type_id: flag_type.id,
            text: 'Updated flag'
          }
        }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when creation fails' do
      it 'returns unprocessable_entity' do
        allow_any_instance_of(Flag).to receive(:save).and_return(false)
        post :create, params: {
          flag: {
            transcript_id: nil,
            transcript_line_id: nil,
            flag_type_id: nil,
            text: ''
          }
        }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    it 'updates the flag and returns no_content' do
      patch :update, params: { id: flag.id, flag: { text: 'Updated' } }, format: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'returns errors on failure' do
      allow_any_instance_of(Flag).to receive(:update).and_return(false)
      patch :update, params: { id: flag.id, flag: { text: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the flag and returns no_content' do
      expect do
        delete :destroy, params: { id: flag.id }, format: :json
      end.to change(Flag, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
