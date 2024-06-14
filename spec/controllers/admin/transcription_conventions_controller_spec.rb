require 'rails_helper'

RSpec.describe Admin::TranscriptionConventionsController, type: :controller do
  render_views

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  let(:transcription_convention) { create(:transcription_convention) }
  let!(:institution) { transcription_convention.institution }
  let(:page) { response.body }

  describe '#index' do
    it "can visit index page" do
      get :index, params: { institution_id: institution.id }

      expect(page).to have_content("Transcription Conventions for #{institution.name}")
      expect(page).to have_content(transcription_convention.convention_key)
      expect(page).to have_content(transcription_convention.convention_text)
      expect(page).to have_content(transcription_convention.example)
    end
  end

  describe '#new' do
    it "can visit new page" do
      get :new, params: { institution_id: institution.id }

      expect(page).to have_content("New record")
      expect(page).to include("transcription_convention[convention_key]")
      expect(page).to include("transcription_convention[convention_text]")
      expect(page).to include("transcription_convention[example]")
    end
  end

  describe "#edit" do
    it "can visit edit page" do
      get :edit, params: { institution_id: institution.id, id: transcription_convention.id }

      expect(page).to have_content("Editing #{transcription_convention.convention_key}")
      expect(page).to include("transcription_convention[convention_key]")
      expect(page).to include("transcription_convention[convention_text]")
      expect(page).to include("transcription_convention[example]")
      expect(page).to include(transcription_convention.convention_key)
      expect(page).to include(transcription_convention.convention_text)
      expect(page).to include(transcription_convention.example)
    end
  end

  describe "#create" do
    it "creates transcription convention" do
      params = {
        institution_id: institution.id,
        transcription_convention: {
          convention_key: "Any convention key",
          convention_text: "Any convention text",
          example: "Any convention example"
        }
      }

      expect { post :create, params: params }.to(
        change { TranscriptionConvention.count }.by(1)
      )
    end
  end

  describe "#update" do
    it "updates transcription convention" do
      params = {
        institution_id: institution.id,
        id: transcription_convention.id,
        transcription_convention: {
          convention_key: "Any convention key",
          convention_text: "Any convention text",
          example: "Any convention example"
        }
      }

      put :update, params: params

      transcription_convention.reload

      expect(transcription_convention.convention_key).to eq "Any convention key"
      expect(transcription_convention.convention_text).to eq "Any convention text"
      expect(transcription_convention.example).to eq "Any convention example"
    end
  end

  describe "#destroy" do
    it "destroy transcriptiopn convention" do
      expect { delete :destroy, params: { institution_id: institution.id, id: transcription_convention.id } }.to(
        change { TranscriptionConvention.count }.by(-1)
      )
    end
  end
end
