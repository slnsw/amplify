# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  controller do
    # Anonymous controller inherits from AdminController
    before_action :authenticate_staff!

    def index
      render 'page/show'
    end
  end

  describe 'layout' do
    before do
      user = build_stubbed(:user)
      allow(user).to receive(:staff?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'uses the admin layout' do
      get :index
      expect(response).to render_template(layout: 'admin')
    end
  end

  describe '#authenticate_staff!' do
    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects to root' do
        get :index

        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is logged in and is a staff member' do
      before do
        user = build_stubbed(:user)
        allow(user).to receive(:staff?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'allows access to the admin area' do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is logged in and is not a staff member' do
      before do
        user = build_stubbed(:user)
        allow(user).to receive(:staff?).and_return(false)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to root' do
        get :index

        expect(response).to redirect_to(root_url)
      end
    end
  end
end
