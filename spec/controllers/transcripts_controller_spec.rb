require 'rails_helper'

RSpec.describe TranscriptsController, type: :controller do
  render_views

  let!(:page) { create(:page, page_type: 'instructions') }
  let!(:public_page) { create(:public_page, page: page) }
  let!(:transcript) { create(:transcript) }

  describe "GET #show" do
    let(:action) { get :show, params: { id: transcript.uid }, format: :json }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end
  end
end
