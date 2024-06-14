require 'rails_helper'

RSpec.describe TranscriptLinesController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let(:flag) { create(:flag) }
  let!(:transcript_line) { flag.transcript_line }

  before { sign_in admin }

  describe '#resolve' do
    it 'visits index page' do
      post :resolve, params: { id: transcript_line.id }

      expect(response).to have_http_status(:success)
    end
  end
end
