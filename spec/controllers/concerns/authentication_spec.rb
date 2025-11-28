# frozen_string_literal: true

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    def index
      authenticate_admin!
      render plain: 'ok' unless performed?
    end

    def moderator_action
      authenticate_moderator!
      render plain: 'ok' unless performed?
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'moderator_action' => 'anonymous#moderator_action'
    end
  end

  describe '#authenticate_admin!' do
    context 'when user is admin' do
      let(:admin) { create(:user, :admin) }

      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
        allow(controller).to receive(:get_current_user).and_return(admin)
      end

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(false)
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:get_current_user).and_return(nil)
      end

      it 'redirects to root' do
        get :index
        expect(response).to be_redirect
      end
    end
  end

  describe '#authenticate_moderator!' do
    context 'when user is moderator' do
      let(:moderator) { create(:user, :moderator) }

      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(moderator)
        allow(controller).to receive(:get_current_user).and_return(moderator)
      end

      it 'allows access' do
        get :moderator_action
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#is_admin?' do
    it 'returns true for admin user' do
      admin = create(:user, :admin)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(admin)
      expect(controller.send(:is_admin?)).to be true
    end

    it 'returns false for non-admin user' do
      user = create(:user)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:is_admin?)).to be false
    end
  end

  describe '#is_moderator?' do
    it 'returns true for moderator user' do
      moderator = create(:user, :moderator)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(moderator)
      expect(controller.send(:is_moderator?)).to be true
    end

    it 'returns false for non-moderator user' do
      user = create(:user)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:is_moderator?)).to be false
    end

    it 'returns false when user is not signed in' do
      allow(controller).to receive(:user_signed_in?).and_return(false)
      expect(controller.send(:is_moderator?)).to be false
    end
  end

  describe '#authentication_failed' do
    it 'redirects HTML requests to root with alert' do
      get :index, format: :html
      expect(response).to be_redirect
    end
  end

  describe '#get_current_user' do
    let(:user) { create(:user) }

    context 'when authHeaders cookie is present' do
      let(:auth_headers) do
        {
          'uid' => user.uid,
          'client' => 'test_client',
          'expiry' => (Time.now + 1.day).to_i.to_s
        }
      end

      before do
        allow(controller.request).to receive(:cookies).and_return({ 'authHeaders' => auth_headers.to_json })
        user.tokens = { 'test_client' => 'test_token' }
        user.save!
      end

      it 'returns current user when valid' do
        result = controller.send(:get_current_user)
        expect(result).to eq(user)
      end
    end

    context 'when authHeaders cookie is not present' do
      before do
        allow(controller.request).to receive(:cookies).and_return({})
      end

      it 'returns nil' do
        result = controller.send(:get_current_user)
        expect(result).to be_nil
      end
    end
  end
end
