# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ThemesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:theme) { create(:theme, name: 'Dark') }

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:authorize).and_return(true)
    allow(controller).to receive(:policy_scope).with(Theme).and_return(Theme.all)
  end

  describe 'GET #index' do
    it 'assigns @themes and renders index' do
      get :index
      expect(assigns(:themes)).to include(theme)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new theme and renders new' do
      get :new
      expect(assigns(:theme)).to be_a_new(Theme)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'assigns the theme and renders edit' do
      get :edit, params: { id: theme.id }
      expect(assigns(:theme)).to eq(theme)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #create' do
    it 'creates a theme and redirects on success' do
      expect do
        post :create, params: { theme: { name: 'Light' } }
      end.to change(Theme, :count).by(1)
      expect(response).to redirect_to(admin_themes_path)
    end

    it 'renders new on failure' do
      expect do
        post :create, params: { theme: { name: '' } }
      end.not_to change(Theme, :count)
      expect(response).to render_template(:new)
    end
  end

  describe 'PATCH #update' do
    it 'updates and redirects on success' do
      patch :update, params: { id: theme.id, theme: { name: 'Updated' } }
      expect(response).to redirect_to(admin_themes_path)
      expect(theme.reload.name).to eq('Updated')
    end

    it 'renders edit on failure' do
      patch :update, params: { id: theme.id, theme: { name: '' } }
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the theme and redirects' do
      expect do
        delete :destroy, params: { id: theme.id }
      end.to change(Theme, :count).by(-1)
      expect(response).to redirect_to(admin_themes_path)
    end
  end

  # Shared examples for admin-only access
  RSpec.shared_examples 'admin-only access' do |resource_factory|
    let(:user) { create(:user) } # non-admin user
    let!(:resource) { resource_factory ? create(resource_factory) : nil }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:authorize).and_call_original
      allow(controller).to receive(:policy_scope).and_call_original
    end

    describe 'GET #new' do
      it 'denies access' do
        expect { get :new }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe 'GET #edit' do
      it 'denies access' do
        expect { get :edit, params: { id: resource&.id } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe 'POST #create' do
      it 'denies access' do
        expect { post :create, params: { theme: { name: 'Test' } } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe 'PATCH #update' do
      it 'denies access' do
        expect do
          patch :update, params: { id: resource&.id, theme: { name: 'Test' } }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe 'DELETE #destroy' do
      it 'denies access' do
        expect do
          delete :destroy, params: { id: resource&.id }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  # Use shared_examples in this controller spec
  describe 'admin-only access' do
    it_behaves_like 'admin-only access', :theme
  end
end
