require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let(:institution) { create(:institution) }
  let(:user_role) { create(:user_role, :content_editor) }

  before { sign_in admin }

  let(:page) { response.body }

  describe "#index" do
    it "visits index page" do
      get :index

      expect(page).to have_content("Registered Users")
      expect(page).to have_content("Administrative Users")

      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content(admin.name)
      expect(page).to have_content(admin.email)
    end
  end

  describe "#update" do
    it "updates user" do
      params = {
        id: user.id,
        user: {
          user_role_id: user_role.id,
          institution_id: institution.id
        }
      }

      put :update, params: params

      user.reload

      expect(user.user_role).to eq user_role
      expect(user.institution).to eq institution
    end
  end

  describe "#destroy" do
    it "destroys user" do
      request.accept = "application/json"
      expect { delete :destroy, params: { id: user.id } }.to(
        change { User.count }.by(-1)
      )
    end
  end
end
