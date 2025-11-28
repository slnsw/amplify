# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
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

      it 'assigns @staff' do
        expect(assigns(:staff)).to be_a(ActiveRecord::Relation)
      end

      it 'assigns @user_roles' do
        expect(assigns(:user_roles)).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe '#update' do
    let(:test_user) { create(:user) }
    let(:update_params) do
      {
        id: test_user.id,
        user: {
          user_role_id: 1
        }
      }
    end

    context 'when requested format is json' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        patch :update, params: update_params, format: :json
      end

      it 'returns no content on success' do
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe '#destroy' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
      end

      it 'destroys the user' do
        user_to_delete = create(:user)
        expect do
          delete :destroy, params: { id: user_to_delete.id }, format: :js, xhr: true
        end.to change(User, :count).by(-1)
      end
    end
  end
end
