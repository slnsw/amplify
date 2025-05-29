require 'rails_helper'

RSpec.describe TranscriptsController, type: :controller do
  render_views

  let!(:instructions_page) { create(:page, page_type: "instructions", published: true) }
  let!(:public_page) { create(:public_page, page: instructions_page) }
  let!(:institution) { create(:institution) }
  let!(:collection) { create(:collection, institution: institution, publish: true) }
  let!(:transcript) { create(:transcript, collection: collection, publish: true, lines: 1) }

  describe "GET #index" do
    it "responds successfully with JSON" do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      # Optionally, check for keys in the JSON response
      json = JSON.parse(response.body) rescue nil
      expect(json).to be_a(Hash).or be_a(Array)
    end
  end

  describe "GET #show" do
    it "responds successfully with JSON" do
      get :show, params: { id: transcript.uid }, format: :json
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      json = JSON.parse(response.body) rescue nil
      expect(json).to be_a(Hash).or be_a(Array)
    end

    it "responds successfully with HTML" do
      get :show, params: { id: transcript.uid }, format: :html
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end

    it "redirects to institution_transcript_path if institution and collection are present and no params[:institution] or params[:collection] or format" do
      # This test is only meaningful if your controller logic triggers this redirect.
      # Simulate the request as /transcripts/:id (not /transcripts/:institution/:collection/:id)
      get :show, params: { id: transcript.uid }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(
        institution_transcript_path(
          transcript.collection.institution.slug,
          transcript.collection.uid,
          transcript.uid
        )
      )
    end
  end
end
