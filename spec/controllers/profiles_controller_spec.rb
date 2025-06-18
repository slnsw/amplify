require "rails_helper"

RSpec.describe Admin::ProfilesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user_role) { admin.user_role }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(user_role).to receive(:update)
  end

  describe "GET #index" do
    it "assigns @user_role" do
      get :index
      expect(assigns(:user_role)).to eq(user_role)
      expect(response).to render_template(:index)
    end
  end

  describe "PATCH #update" do
    context "when updating transcribing role" do
      let(:params) do
        {
          id: admin.id,
          user_role: {
            commit: "update_transcribing_role",
            transcribing_role: "editor",
          },
        }
      end

      it "updates the transcribing role and sets flash notice" do
        expect(user_role).to receive(:update).with(transcribing_role: "editor")
        patch :update, params: params
        expect(flash[:notice]).to eq("Admin's transcribing role has been updated to editor.")
        expect(response).to redirect_to(admin_profiles_path)
      end
    end

    context "when not updating transcribing role" do
      it "just redirects" do
        patch :update, params: { id: admin.id, user_role: { commit: "something_else" } }
        expect(response).to redirect_to(admin_profiles_path)
      end
    end

    context "when current_user is not admin" do
      before { allow(admin).to receive(:admin?).and_return(false) }

      it "does not update the transcribing role" do
        expect(user_role).not_to receive(:update)
        patch :update, params: { id: admin.id, user_role: { commit: "update_transcribing_role", transcribing_role: "editor" } }
        expect(flash[:notice]).to be_nil
        expect(response).to redirect_to(admin_profiles_path)
      end
    end
  end
end
