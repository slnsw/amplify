require 'rails_helper'

RSpec.describe TranscriptSpeakerEditsController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let(:flag) { create(:flag) }
  let(:transcript_line) { flag.transcript_line }
  let!(:transcript_speaker) { create(:transcript_speaker, transcript: transcript_line.transcript) }

  before { sign_in admin }

  describe '#create' do
    it 'creates new TranscriptSpeakerEdit' do
      request.accept = "application/json"
      expect do
        post :create, params: {
          transcript_speaker_edit: {
            transcript_id: transcript_line.transcript_id,
            transcript_line_id: transcript_line.id,
            user_id: admin.id,
            speaker_id: transcript_speaker.speaker_id
          }
        }
      end.to change { TranscriptSpeakerEdit.count }.by(1)
    end
  end
end
