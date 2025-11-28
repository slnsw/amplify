# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PagesController, type: :controller do
  let(:page) { create(:page) }

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

    context 'when user is non admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :index
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is anonymous' do
      it 'redirects' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#show' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :show, params: { id: page.id }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is non admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :show, params: { id: page.id }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is anonymous' do
      it 'redirects' do
        get :show, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#create' do
    let(:params) { { page: { page_type: 'faq', content: 'some string' } } }

    context 'when user is admin and create succeeds' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        post :create, params: params
      end

      it 'redirects to pages index' do
        expect(response).to redirect_to(admin_pages_path)
      end
    end

    context 'when create fails' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        allow_any_instance_of(Page).to receive(:save).and_return(false) # rubocop:disable RSpec/AnyInstance
        post :create, params: params
      end

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end
    end

    context 'when user is non admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        post :create, params: params
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is anonymous' do
      it 'redirects' do
        post :create, params: params
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#update' do
    let(:params) { { id: page.id, page: { content: 'updated content' } } }

    context 'when user is admin and update succeeds' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        patch :update, params: params
      end

      it 'redirects to pages index' do
        expect(response).to redirect_to(admin_pages_path)
      end
    end

    context 'when update fails' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        allow_any_instance_of(Page).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance
        patch :update, params: params
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#edit' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :edit, params: { id: page.id }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is non admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :edit, params: { id: page.id }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is anonymous' do
      it 'redirects' do
        get :edit, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#destroy' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        delete :destroy, params: { id: page.id }
      end

      it 'redirects to pages index' do
        expect(response).to redirect_to(admin_pages_path)
      end
    end

    context 'when user is non admin' do
      let(:user) { create(:user) }

      before do
        sign_in user
        delete :destroy, params: { id: page.id }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is anonymous' do
      it 'redirects' do
        delete :destroy, params: { id: page.id }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
