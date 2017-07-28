require 'rails_helper'

RSpec.describe Admin::Cms::CollectionsController, type: :controller do
  let(:vendor) { Vendor.create!(uid: 'voice_base', name: 'VoiceBase') }
  let(:collection) do
    Collection.create!(
      description: "A summary of the collection's content",
      url: "collection_catalogue_reference",
      uid: "collection-uid",
      title: "The collection's title",
      vendor: vendor
    )
  end
  let(:user) do
    User.create!(
      email: "user@email.com",
      password: "password",
      user_role: UserRole.create!(name: "admin", hiearchy: 100)
    )
  end

  before do
    sign_in user
  end

  describe "GET #show" do
    let(:action) { get :show, id: collection.uid }

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
          image: File.open(Rails.root.join('spec', 'fixtures', 'image.jpg')),
          vendor_id: vendor.id
        }
      end
      let(:action) { post :create, collection: params }

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
      let(:params) { { uid: "" } }
      let(:action) { post :create, collection: params }

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
        end.to_not change { Collection.count }
      end
    end
  end

  describe "GET #edit" do
    let(:action) { get :edit, id: collection.uid }

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
        { title: "Revised title" }
      end
      let(:action) { put :update, id: collection.uid, collection: params }

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
        end.to change { collection.reload.title }
          .from("The collection's title").to("Revised title")
      end
    end

    context "invalid update request" do
      let(:params) { { uid: "" } }
      let(:action) { put :update, id: collection.uid, collection: params }

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
        end.to_not change { collection.reload.uid }
      end
    end
  end
end
