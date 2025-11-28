# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ProfilesController, type: :controller do
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

      it 'assigns @user_role' do
        expect(assigns(:user_role)).to eq(user.user_role)
      end
    end

    context 'when user is non-admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :index
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user, :admin) }
    let(:update_params) do
      {
        id: user.id,
        user_role: {
          transcribing_role: 'admin',
          commit: 'update_transcribing_role'
        }
      }
    end

    context 'when updating transcribing role as admin' do
      before do
        sign_in user
        patch :update, params: update_params
      end

      it 'redirects after update' do
        expect(response).to redirect_to(admin_profiles_path)
      end
    end
  end
end
