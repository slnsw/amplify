require "rails_helper"

RSpec.describe Admin::Cms::CollectionsController, type: :controller do
  let(:vendor) { Vendor.create!(uid: "voice_base", name: "VoiceBase") }
  let(:institution) { FactoryBot.create :institution }
  let(:collection) do
    Collection.create!(
      description: "A summary of the collection's content",
      url: "collection_catalogue_reference",
      uid: "collection-uid",
      title: "The collection's title",
      vendor: vendor,
      institution_id: institution.id,
    )
  end
  let(:user) { create(:user, :admin, email: "user@email.com", password: "password") }

  before do
    sign_in user
  end

  describe "GET #show" do
    let(:action) { get :show, params: { id: collection.uid } }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "displays the collection with related items" do
      action
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    let(:action) { get :new }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "displays the form to create a new collection" do
      action
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "valid request" do
      let(:params) do
        {
          uid: "new_collection",
          title: "New collection title",
          description: "New description of collection",
          url: "new_collection_catalogue_reference",
          image: File.open(Rails.root.join("spec", "fixtures", "image.jpg")),
          vendor_id: vendor.id,
          institution_id: institution.id,
          theme_ids: [""],
        }
      end
      let(:action) { post :create, params: { collection: params } }

      it "is successful" do
        action
        expect(response).to have_http_status(:found)
      end

      it "displays the cms dashboard" do
        action
        expect(response).to be_redirect
      end
    end

    context "invalid request" do
      let(:params) { { uid: "", theme_ids: [""] } }
      let(:action) { post :create, params: { collection: params } }

      it "responds with a bad request status" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays the collection form again" do
        action
        expect(response).to render_template(:new)
      end

      it "does not create a new collection" do
        expect do
          action
        end.not_to change(Collection, :count)
      end
    end
  end

  describe "GET #edit" do
    let(:action) { get :edit, params: { id: collection.uid } }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "displays the form to edit an existing collection" do
      action
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    context "valid update request" do
      let(:params) do
        { title: "Revised title", theme_ids: [""] }
      end
      let(:action) { put :update, params: { id: collection.uid, collection: params } }

      it "is successful" do
        action
        expect(response).to have_http_status(:found)
      end

      it "displays the cms dashboard" do
        action
        expect(response).to be_redirect
      end

      it "updates the collection" do
        expect do
          action
        end.to change { collection.reload.title }.
          from("The collection's title").to("Revised title")
      end
    end

    context "invalid update request" do
      let(:params) { { uid: "", theme_ids: [""] } }
      let(:action) { put :update, params: { id: collection.uid, collection: params } }

      it "responds with a bad request status" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays the collection edit form again" do
        action
        expect(response).to render_template(:edit)
      end

      it "does not update the collection" do
        expect do
          action
        end.not_to change { collection.reload.uid }
      end
    end
  end
end
