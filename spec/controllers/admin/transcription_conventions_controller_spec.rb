require 'rails_helper'

RSpec.describe Admin::TranscriptionConventionsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:institution) { create(:institution) }
  let!(:transcription_convention) { create(:transcription_convention, institution: institution) }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:authorize).and_return(true)
  end

  describe "GET #index" do
    it "assigns @transcription_conventions and renders index" do
      get :index, params: { institution_id: institution.id }
      expect(assigns(:transcription_conventions)).to include(transcription_convention)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    it "assigns a new transcription_convention and renders new" do
      get :new, params: { institution_id: institution.id }
      expect(assigns(:transcription_convention)).to be_a_new(TranscriptionConvention)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns the transcription_convention and renders edit" do
      get :edit, params: { institution_id: institution.id, id: transcription_convention.id }
      expect(assigns(:transcription_convention)).to eq(transcription_convention)
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    it "creates a transcription_convention and redirects on success" do
      expect {
        post :create, params: {
          institution_id: institution.id,
          transcription_convention: attributes_for(:transcription_convention)
        }
      }.to change(TranscriptionConvention, :count).by(1)
      expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
    end

    it "renders new on failure" do
      expect {
        post :create, params: {
          institution_id: institution.id,
          transcription_convention: { convention_key: "" }
        }
      }.to change(TranscriptionConvention, :count).by(1)
      expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
    end
  end

  describe "PATCH #update" do
    it "updates and redirects on success" do
      patch :update, params: {
        institution_id: institution.id,
        id: transcription_convention.id,
        transcription_convention: { convention_key: "Updated" }
      }
      expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
      expect(transcription_convention.reload.convention_key).to eq("Updated")
    end

    it "redirects on update even with blank convention_key" do
      patch :update, params: {
        institution_id: institution.id,
        id: transcription_convention.id,
        transcription_convention: { convention_key: "" }
      }
      expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
    end
  end

  describe "DELETE #destroy" do
    it "destroys the transcription_convention and redirects" do
      expect {
        delete :destroy, params: { institution_id: institution.id, id: transcription_convention.id }
      }.to change(TranscriptionConvention, :count).by(-1)
      expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
    end
  end
end