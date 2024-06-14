require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }
  let(:collection) { create(:collection) }
  let!(:institution) { collection.institution }

  before { sign_in admin }

  let(:page) { response.body }

  describe "#index" do
    it "visits index page" do
      create(:page, page_type: "collection")

      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe "#list" do
    it "visit list page" do
      post :list, params: { institution_slug: institution.slug }, format: :js

      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    it "visit show page" do
      collection = create(:collection)

      get :show, params: { id: collection.uid }, format: :json

      expect(response).to have_http_status(:success)
    end
  end
end
