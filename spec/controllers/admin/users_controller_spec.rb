require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:authorize).and_return(true)
  end

  describe "GET #index" do
    it "renders index" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "PATCH #update" do
    it "updates the user and returns no_content" do
      patch :update, params: { id: user.id, user: { user_role_id: user.user_role_id, institution_id: user.institution_id } }, format: :json
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the user and returns no_content" do
      expect {
        delete :destroy, params: { id: user.id }, format: :json
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end