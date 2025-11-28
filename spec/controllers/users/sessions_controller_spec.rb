# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#new' do
    context 'when not signed in' do
      it 'is successful' do
        get :new
        expect(response).to be_successful
      end
    end

    context 'when signed in' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'redirects away from new' do
        get :new
        expect(response).not_to be_successful
      end
    end
  end

  describe '#create' do
    it 'permits sign_in params via sanitizer' do
      sanitizer = controller.devise_parameter_sanitizer
      allow(sanitizer).to receive(:permit)
      post :create, params: { user: { email: 'a@b.com', password: 'secret' } }
      expect(sanitizer).to have_received(:permit).with(:sign_in, keys: [:attribute])
    end
  end
end
