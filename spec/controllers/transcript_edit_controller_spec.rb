require 'rails_helper'

RSpec.describe TranscriptEditsController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let(:page) { response.body }
  let(:response_json) { JSON.parse(page) }
  let!(:transcript_edit) { create(:transcript_edit) }

  before { sign_in admin }

  describe '#index' do
    before do
      request.accept = "application/json"
      get :index, params: params
    end

    context 'with transcript_line_id params' do
      let(:params) { { transcript_line_id: transcript_edit.transcript_line.id } }

      it 'respond with json' do
        expect(response_json['edits']).not_to be_empty
      end
    end

    context 'when user_id params' do
      let(:params) { { user_id: transcript_edit.user_id } }

      it 'respond with json' do
        expect(response_json['edits']).not_to be_empty
      end
    end
  end

  describe '#show' do
    it 'respond with json' do
      request.accept = "application/json"
      get :show, params: { id: transcript_edit.id }

      expect(response_json).to eq transcript_edit.as_json.except('is_deleted')
    end
  end

  describe '#create' do
    it 'creates transcript edit' do
      allow_any_instance_of(TranscriptLine).to receive(:recalculate)

      transcript_line = create(:transcript_line)
      params = {
        transcript_edit: {
          transcript_id: transcript_line.transcript.id,
          transcript_line_id: transcript_line.id,
          user_id: admin.id,
          text: 'any text',
          is_deleted: 0
        }
      }

      request.accept = "application/json"
      expect { post :create, params: params }.to(
        change { TranscriptEdit.count }.by(1)
      )
    end
  end

  # Note (jonjon): uncomment this when this actions added to routes
  xdescribe '#update' do
    it 'updates transcript edit' do
      allow_any_instance_of(TranscriptLine).to receive(:recalculate)

      params = {
        id: transcript_edit.id,
        transcript_edit: {
          transcript_id: transcript_edit.transcript_line.transcript.id,
          transcript_line_id: transcript_edit.transcript_line.id,
          user_id: transcript_edit.user_id,
          text: 'any text',
          is_deleted: 0
        }
      }

      request.accept = "application/json"
      put :update, params: params

      transcript_edit.reload

      expect(transcript_edit.text).to eq 'any text'
    end
  end

  # Note (jonjon): uncomment this when this actions added to routes
  xdescribe '#destroy' do
    it 'destroy transcript edit' do
      expect { delete :destroy, params: { id: transcript_edit.id } }.to(
        change { TranscriptEdit.count }.by(-1)
      )
    end
  end
end
