require 'rails_helper'

RSpec.describe Admin::TranscriptsController, type: :controller do
  render_views

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  let(:page) { response.body }

  describe "#index" do
    context "json" do
      it "visits index page" do
        request.accept = "application/json"
        get :index

        expect(JSON.parse(page).keys).to contain_exactly("entries")
      end
    end

    context "html" do
      it "visits index page" do
        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end
end
