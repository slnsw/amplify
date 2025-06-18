require "rails_helper"

RSpec.describe AmplifyBaseController, type: :controller do
  controller do
    def index
      render plain: "OK"
    end
  end

  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "authentication" do
    it "calls authenticate_user! before actions" do
      expect(controller).to receive(:authenticate_user!)
      get :index
    end
  end

  describe "GET #index" do
    it "responds successfully" do
      get :index
      expect(response).to be_successful
      expect(response.body).to eq("OK")
    end
  end
end
