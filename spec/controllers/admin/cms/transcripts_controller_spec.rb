require "rails_helper"

RSpec.describe Admin::Cms::TranscriptsController, type: :controller do
  let(:institution) { FactoryBot.create :institution }
  let(:collection) do
    Collection.create!(
      description: "A summary of the collection's content",
      url: "collection_catalogue_reference",
      uid: "collection-uid",
      title: "The collection's title",
      vendor: Vendor.create(uid: "voice_base", name: "VoiceBase"),
      institution_id: institution.id,
    )
  end
  let(:transcript) do
    Transcript.create!(
      uid: "transcript-uid",
      title: "The transcript title",
      description: "A summary of the transcript's content",
      url: "transcript_catalogue_reference",
      audio_url: "s3_audio_url",
      image_url: "s3_image_url",
      transcript_status: TranscriptStatus.create(name: "initialized", progress: 0, description: "Transcript initialized"),
      collection: collection,
      vendor: collection.vendor,
    )
  end
  let(:speaker) do
    Speaker.create!(name: "Jane Bloggs")
  end
  let(:user) { create(:user, :admin, email: "user@email.com", password: "password") }

  before do
    sign_in user
  end

  describe "GET #new" do
    let(:action) { get :new, params: { collection_uid: collection.uid } }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "displays the form to create a new transcript" do
      action
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "valid request" do
      let(:params) do
        {
          uid: "new_transcript",
          audio: File.open(Rails.root.join("spec", "fixtures", "audio.mp3")),
          script: File.open(Rails.root.join("spec", "fixtures", "transcript.srt")),
          image: File.open(Rails.root.join("spec", "fixtures", "image.jpg")),
          vendor_id: collection.vendor.id,
          collection_id: collection.id,
          speakers: "Anonymous",
        }
      end
      let(:action) { post :create, params: { transcript: params } }

      it "is successful" do
        action
        expect(response).to have_http_status(:found)
      end

      it "displays the collection with list of transcripts" do
        action
        expect(response).to be_redirect
      end

      it "creates a new transcript" do
        expect do
          action
        end.to change(Transcript, :count)
      end

      it "saves speaker data" do
        action
        expect(Transcript.last.speakers).to eq "Anonymous; "
      end
    end

    context "invalid request" do
      let(:params) { { uid: "", speakers: "" } }
      let(:action) { post :create, params: { transcript: params } }

      it "responds with a bad request status" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays the transcript form again" do
        action
        expect(response).to render_template(:new)
      end

      it "does not create a new transcript" do
        expect do
          action
        end.not_to change(Transcript, :count)
      end
    end
  end

  describe "GET #edit" do
    let(:action) { get :edit, params: { id: transcript.id } }

    it "is successful" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "displays the form to edit a new transcript" do
      action
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    context "valid update request" do
      let(:params) do
        { title: "Revised title", speakers: "John Doe" }
      end
      let(:action) { put :update, params: { id: transcript.uid, transcript: params } }

      it "is successful" do
        action
        expect(response).to have_http_status(:found)
      end

      it "displays the collection with list of transcripts" do
        action
        expect(response).to be_redirect
      end

      it "updates the transcript" do
        expect do
          action
        end.to change { transcript.reload.title }.
          from("The transcript title").to("Revised title")
      end
    end

    context "invalid update request" do
      let(:params) { { uid: "", speakers: "" } }
      let(:action) { put :update, params: { id: transcript.uid, transcript: params } }

      it "responds with a bad request status" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays the transcript edit form again" do
        action
        expect(response).to render_template(:edit)
      end

      it "does not update the transcript" do
        expect do
          action
        end.not_to change { transcript.reload.uid }
      end
    end
  end

  describe "GET speaker_search" do
    context "valid request" do
      let (:action) { post :speaker_search, params: { query: "jane" } }

      it "responds with an ok status" do
        action
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST process_transcript" do
    context "valid request" do
      let (:action) { post :process_transcript, params: { id: transcript.id } }

      it "responds with an ok status" do
        action
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "update_multiple" do
    context "when publishing" do
      let(:transcripts) { create_list(:transcript, 3) }
      let(:transcript) { transcripts.first }
      let(:action) { patch :update_multiple, params: { commit: "publish", transcript_ids: transcripts.map(&:uid), collection_uid: transcript.collection.uid }, format: :js }

      it "publishes all transcripts" do
        action
        transcript.reload
        expect(transcript.publish).to be_truthy
        expect(transcript.published_at).to be_truthy

        transcript.update(title: Faker::Lorem.sentence)
        transcript.reload

        expect(transcript.publish).to be_truthy
        expect(transcript.published_at).to be_truthy
      end
    end

    context "when publishing" do
      let(:transcripts) { create_list(:transcript, 3, :published) }
      let(:transcript) { transcripts.first }
      let(:action) { patch :update_multiple, params: { commit: "unpublish", transcript_ids: transcripts.map(&:uid), collection_uid: transcript.collection.uid }, format: :js }

      it "publishes all transcripts" do
        action
        transcript.reload
        expect(transcript.publish).to be_falsy
        expect(transcript.published_at).to be_falsy

        transcript.update(title: Faker::Lorem.sentence)
        transcript.reload

        expect(transcript.publish).to be_falsy
        expect(transcript.published_at).to be_falsy
      end
    end
  end
end
