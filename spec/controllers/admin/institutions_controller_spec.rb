# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::InstitutionsController, type: :controller do
  let(:institution) { create(:institution) }

  describe '#index' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :index
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#new' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :new
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#edit' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :edit, params: { id: institution.slug }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#create' do
    let(:institution_params) do
      {
        institution: {
          name: 'New Institution'
        }
      }
    end

    context 'when user is admin and create succeeds' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        post :create, params: institution_params
      end

      it 'redirects to institutions index' do
        expect(response).to redirect_to(admin_institutions_path)
      end
    end

    context 'when create fails' do
      let(:user) { create(:user, :admin) }
      let(:institution_double) { instance_double(Institution, save: false) }

      before do
        sign_in user
        allow(Institution).to receive(:new).and_return(institution_double)
        post :create, params: institution_params
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:update_params) do
      {
        id: institution.slug,
        institution: {
          name: 'Updated Name',
          institution_links: []
        }
      }
    end

    context 'when user is admin and update succeeds' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        patch :update, params: update_params
      end

      it 'redirects to institutions index' do
        expect(response).to redirect_to(admin_institutions_path)
      end
    end

    context 'when update fails' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        allow_any_instance_of(Institution).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance
        patch :update, params: update_params
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        delete :destroy, params: { id: institution.slug }
      end

      it 'redirects to institutions index' do
        expect(response).to redirect_to(admin_institutions_path)
      end
    end
  end
end
