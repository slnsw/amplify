require 'rails_helper'

RSpec.describe Admin::ThemesController, type: :controller do
  render_views

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  let!(:theme) { create(:theme) }
  let(:page) { response.body }

  describe '#index' do
    it "can visit index page" do
      get :index

      expect(page).to have_content("Themes")
      expect(page).to have_content(theme.name)
    end
  end

  describe '#edit' do
    it "can visit index page" do
      get :edit, params: { id: theme.id }

      expect(page).to have_content("Editing Theme")
      expect(page).to include("name")
      expect(page).to include(theme.name)
    end
  end

  describe '#create' do
    it "creates theme" do
      expect {  post :create, params: { theme: { name: "Any theme name" } } }.to(
        change { Theme.count }.by(1)
      )
    end
  end

  describe '#create' do
    it "updates theme" do
      put :update, params: {  id: theme.id, theme: { name: "Any theme name" } }

      theme.reload

      expect(theme.name).to eq "Any theme name"
    end
  end

  describe '#destroy' do
    it "destroys theme" do
      expect { delete :destroy, params: {  id: theme.id } }.to(
        change { Theme.count }.by(-1)
      )
    end
  end
end
