require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do

  describe "GET #index" do
    let!(:published_institution1) { create(:institution, name: "Alpha Institution", hidden: false) }
    let!(:published_institution2) { create(:institution, name: "Beta Institution", hidden: false) }
    let!(:unpublished_institution) { create(:institution, name: "Hidden Institution", hidden: true) }

    before do
      get :index
    end

    it "assigns @institutions to only include published institutions" do
      expect(assigns(:institutions)).to match_array([published_institution1, published_institution2])
    end

    it "does not include hidden institutions" do
      expect(assigns(:institutions)).not_to include(unpublished_institution)
    end

    it "assigns @institutions sorted by name" do
      expect(assigns(:institutions)).to eq([published_institution1, published_institution2])
    end
  end
end
