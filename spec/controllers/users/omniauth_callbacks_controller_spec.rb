require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  routes { Rails.application.routes }

  let(:user) { create(:user) }
  let(:auth_hash) do
    {
      'provider' => 'facebook',
      'uid' => '123456',
      'info' => { 'email' => 'test@example.com', 'name' => 'Test User' }
    }
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = auth_hash
    allow(User).to receive(:from_omniauth).and_return(user)
    allow(controller).to receive(:remember_me)
    allow(controller).to receive(:sign_in)
    allow(controller).to receive(:set_flash_message)
  end

  describe "GET #facebook" do
    context "when user is persisted" do
      before { allow(user).to receive(:persisted?).and_return(true) }

      it "signs in and redirects" do
        get :facebook
        expect(controller).to have_received(:remember_me).with(user)
        expect(controller).to have_received(:sign_in).with(user, event: :authentication)
        expect(response).to redirect_to("/")
      end
    end

    context "when user is not persisted" do
      before { allow(user).to receive(:persisted?).and_return(false) }

      it "redirects to registration" do
        get :facebook
        expect(response).to redirect_to(new_user_registration_url)
      end
    end
  end

  describe "GET #google_oauth2" do
    before do
      request.env["omniauth.auth"]['provider'] = 'google_oauth2'
    end

    context "when user is persisted" do
      before { allow(user).to receive(:persisted?).and_return(true) }

      it "signs in and redirects" do
        get :google_oauth2
        expect(controller).to have_received(:remember_me).with(user)
        expect(controller).to have_received(:sign_in).with(user, event: :authentication)
        expect(response).to redirect_to("/")
      end
    end

    context "when user is not persisted" do
      before { allow(user).to receive(:persisted?).and_return(false) }

      it "redirects to registration" do
        get :google_oauth2
        expect(response).to redirect_to(new_user_registration_url)
      end
    end
  end

  describe "private #redirect_url" do
    controller(Users::OmniauthCallbacksController) do
      public :redirect_url
    end

    it "returns / if no state param" do
      expect(controller.redirect_url).to eq("/")
    end

    it "returns institution_transcript_path if state param and transcript exists" do
      transcript = create(:transcript, uid: "abc123")
      collection = double(uid: "col1", institution: double(slug: "inst1"))
      allow(transcript).to receive(:collection).and_return(collection)
      allow(Transcript).to receive(:find_by).with(uid: "abc123").and_return(transcript)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new("state" => "abc123"))
      expect(controller.redirect_url).to eq(
        Rails.application.routes.url_helpers.institution_transcript_path(
          institution: "inst1", collection: "col1", id: "abc123"
        )
      )
    end
  end
end