require 'rails_helper'

RSpec.describe TranscriptFilesController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let(:transcript_edit) { create(:transcript_edit) }
  let(:transcript) { transcript_edit.transcript }
  let!(:transcript_speaker) { create(:transcript_speaker, transcript: transcript) }
  let(:json_response) { JSON.parse(response.body) }

  before { sign_in admin }

  describe '#index' do
    it 'visits index page' do
      request.accept = "application/json"
      get :index, params: { updated_after: Date.current.strftime('%Y-%m-%d') }

      expect(response).to have_http_status(:success)
    end
  end

  describe '#show' do
    before do
      request.accept = "application/json"
      get :show, params: params
    end

    context 'with edits' do
      let(:params) { { id: transcript.uid, edit: 1 } }

      it 'responds with json' do
        expect(json_response.keys).to contain_exactly(
          "id",
          "url",
          "last_updated",
          "title",
          "description",
          "audio_url",
          "image_url",
          "duration",
          "lines",
          "speakers",
          "statuses"
        )
      end
    end

    context 'with speaker' do
      let(:params) { { id: transcript.uid, speaker: 1 } }

      it 'responds with json' do
        expect(json_response.keys).to contain_exactly(
          "id",
          "url",
          "last_updated",
          "title",
          "description",
          "audio_url",
          "image_url",
          "duration",
          "lines",
          "speakers",
          "statuses"
        )
      end
    end
  end
end
