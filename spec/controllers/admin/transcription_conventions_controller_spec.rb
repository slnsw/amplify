# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TranscriptionConventionsController, type: :controller do
  let(:institution) { create(:institution) }
  let(:transcription_convention) { create(:transcription_convention, institution: institution) }

  describe '#index' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        get :index, params: { institution_id: institution.slug }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @transcription_conventions' do
        expect(assigns(:transcription_conventions)).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe '#new' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        get :new, params: { institution_id: institution.slug }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#edit' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        get :edit, params: { institution_id: institution.slug, id: transcription_convention.id }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#create' do
    let(:convention_params) do
      {
        institution_id: institution.slug,
        transcription_convention: {
          convention_key: 'test_key',
          convention_text: 'Test convention text'
        }
      }
    end

    context 'when user is staff and create succeeds' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        post :create, params: convention_params
      end

      it 'redirects to institution transcription conventions' do
        expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
      end
    end

    context 'when create fails' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow_any_instance_of(TranscriptionConvention).to receive(:save).and_return(false) # rubocop:disable RSpec/AnyInstance
        post :create, params: convention_params
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:update_params) do
      {
        institution_id: institution.slug,
        id: transcription_convention.id,
        transcription_convention: {
          convention_text: 'Updated text'
        }
      }
    end

    context 'when user is staff and update succeeds' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        patch :update, params: update_params
      end

      it 'redirects to institution transcription conventions' do
        expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
      end
    end

    context 'when update fails' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow_any_instance_of(TranscriptionConvention).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance
        patch :update, params: update_params
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        delete :destroy, params: { institution_id: institution.slug, id: transcription_convention.id }
      end

      it 'redirects to institution transcription conventions' do
        expect(response).to redirect_to(admin_institution_transcription_conventions_path(institution))
      end
    end
  end
end
