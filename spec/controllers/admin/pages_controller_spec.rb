require "rails_helper"

RSpec.describe Admin::PagesController, type: :controller do
  let(:page) { create(:page) }

  describe "admin access" do
    let(:user) { create(:user, :admin) }

    before do
      sign_in user
    end

    describe "#index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "#show" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end
    end

    describe "#create" do
      it "is successful" do
        post :create, params: { page: { page_type: "faq", content: "some string" } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#edit" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end
    end

    describe "#destroy" do
      it "is successful" do
        delete :destroy, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "non admin access" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    describe "#index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#show" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#create" do
      it "is successful" do
        post :create, params: { page: { page_type: "faq", content: "some string" } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#edit" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#destroy" do
      it "is successful" do
        delete :destroy, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "annonymous access" do
    describe "#index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#show" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#create" do
      it "is successful" do
        post :create, params: { page: { page_type: "faq", content: "some string" } }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#edit" do
      it "is successful" do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "#destroy" do
      it "is successful" do
        delete :destroy, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
