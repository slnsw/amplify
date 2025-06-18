require "rails_helper"

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    def index
      head :ok
    end

    def fail
      authentication_failed
    end

    def moderator_url
      "/moderator"
    end

    def root_url(_options = {})
      "/root"
    end
  end

  let(:user) { double("User", uid: "123", tokens: { "abc" => {} }, isAdmin?: false, isModerator?: false) }
  let(:admin) { double("User", uid: "admin", tokens: { "abc" => {} }, isAdmin?: true, isModerator?: false) }
  let(:moderator) { double("User", uid: "mod", tokens: { "abc" => {} }, isAdmin?: false, isModerator?: true) }
  let(:valid_headers) do
    {
      "uid" => user.uid,
      "client" => "abc",
      "expiry" => (DateTime.now.to_i + 3600).to_s,
    }
  end

  before do
    routes.draw do
      get "index" => "anonymous#index"
      get "fail" => "anonymous#fail"   # <-- Add this line
    end
    allow(controller).to receive(:respond_to).and_call_original
  end

  describe "#get_current_user" do
    it "returns nil if authHeaders cookie is missing" do
      allow(controller.request).to receive(:cookies).and_return({})
      expect(controller.get_current_user).to be_nil
    end

    it "returns nil if user not found" do
      allow(controller.request).to receive(:cookies).and_return({ "authHeaders" => valid_headers.to_json })
      allow(User).to receive(:find_by).with(uid: user.uid).and_return(nil)
      expect(controller.get_current_user).to be_nil
    end

    it "returns nil if client token missing" do
      allow(controller.request).to receive(:cookies).and_return({ "authHeaders" => valid_headers.to_json })
      user_no_token = double("User", uid: user.uid, tokens: {}, isAdmin?: false, isModerator?: false)
      allow(User).to receive(:find_by).with(uid: user.uid).and_return(user_no_token)
      expect(controller.get_current_user).to be_nil
    end

    it "returns nil if token expired" do
      expired_headers = valid_headers.merge("expiry" => (DateTime.now.to_i - 3600).to_s)
      allow(controller.request).to receive(:cookies).and_return({ "authHeaders" => expired_headers.to_json })
      allow(User).to receive(:find_by).with(uid: user.uid).and_return(user)
      expect(controller.get_current_user).to be_nil
    end

    it "returns user if all checks pass" do
      allow(controller.request).to receive(:cookies).and_return({ "authHeaders" => valid_headers.to_json })
      allow(User).to receive(:find_by).with(uid: user.uid).and_return(user)
      expect(controller.get_current_user).to eq(user)
    end
  end

  describe "#is_admin?" do
    it "returns true if user_signed_in? and user is admin" do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(admin)
      expect(controller.is_admin?).to be true
    end

    it "returns false if not signed in" do
      allow(controller).to receive(:user_signed_in?).and_return(false)
      expect(controller.is_admin?).to be false
    end

    it "returns false if user is not admin" do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.is_admin?).to be false
    end
  end

  describe "#is_moderator?" do
    it "returns true if user_signed_in? and user is moderator" do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(moderator)
      expect(controller.is_moderator?).to be true
    end

    it "returns false if not signed in" do
      allow(controller).to receive(:user_signed_in?).and_return(false)
      expect(controller.is_moderator?).to be false
    end

    it "returns false if user is not moderator" do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.is_moderator?).to be false
    end
  end

  describe "#authenticate_admin!" do
    it "redirects to moderator_url if user is moderator" do
      allow(controller).to receive(:get_current_user)
      allow(controller).to receive(:is_admin?).and_return(false)
      allow(controller).to receive(:is_moderator?).and_return(true)
      expect(controller).to receive(:redirect_to).with("/moderator")
      controller.authenticate_admin!
    end

    it "calls authentication_failed if not admin or moderator" do
      allow(controller).to receive(:get_current_user)
      allow(controller).to receive(:is_admin?).and_return(false)
      allow(controller).to receive(:is_moderator?).and_return(false)
      expect(controller).to receive(:authentication_failed)
      controller.authenticate_admin!
    end

    it "does nothing if user is admin" do
      allow(controller).to receive(:get_current_user)
      allow(controller).to receive(:is_admin?).and_return(true)
      expect(controller).not_to receive(:redirect_to)
      expect(controller).not_to receive(:authentication_failed)
      controller.authenticate_admin!
    end
  end

  describe "#authenticate_moderator!" do
    it "calls authentication_failed if not moderator" do
      allow(controller).to receive(:get_current_user)
      allow(controller).to receive(:is_moderator?).and_return(false)
      expect(controller).to receive(:authentication_failed)
      controller.authenticate_moderator!
    end

    it "does nothing if user is moderator" do
      allow(controller).to receive(:get_current_user)
      allow(controller).to receive(:is_moderator?).and_return(true)
      expect(controller).not_to receive(:authentication_failed)
      controller.authenticate_moderator!
    end
  end

  describe "#authentication_failed" do
    it "redirects to root_url for html format" do
      get :fail, format: :html
      expect(response).to redirect_to("/root")
    end

    it "renders json for json format" do
      get :fail, format: :json
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({
                                                "error" => 1,
                                                "message" => "You must log in as admin to access this section.",
                                              })
    end
  end
end
