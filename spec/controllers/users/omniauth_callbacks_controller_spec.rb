# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#facebook' do
    let(:auth) { { 'provider' => 'facebook', 'uid' => '123' } }

    context 'when user persisted' do
      let(:user) { build_stubbed(:user) }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return(user)
        request.env['omniauth.auth'] = auth
        allow(controller).to receive(:remember_me)
        allow(controller).to receive(:sign_in)
        allow(controller).to receive(:set_flash_message)
        get :facebook, as: :json
      end

      it 'calls remember_me' do
        expect(controller).to have_received(:remember_me).with(user)
      end

      it 'signs in the user' do
        expect(controller).to have_received(:sign_in).with(user, event: :authentication)
      end
    end

    context 'when user not persisted' do
      let(:user) { build(:user) }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return(user)
        request.env['omniauth.auth'] = auth
        allow(controller).to receive(:redirect_to) do |arg|
          controller.instance_variable_set(:@redirect_target, arg)
        end
        get :facebook, as: :json
      end

      it 'stores omniauth data in session' do
        expect(session['devise.facebook_data']).to eq(auth)
      end

      it 'redirects to registration' do
        expect(controller.instance_variable_get(:@redirect_target)).to eq(new_user_registration_url)
      end
    end
  end

  describe '#google_oauth2' do
    let(:auth) { { 'provider' => 'google_oauth2', 'uid' => '999' } }

    context 'when user persisted' do
      let(:user) { build_stubbed(:user) }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return(user)
        request.env['omniauth.auth'] = auth
        allow(controller).to receive(:remember_me)
        allow(controller).to receive(:sign_in)
        allow(controller).to receive(:set_flash_message)
        get :google_oauth2, as: :json
      end

      it 'calls remember_me' do
        expect(controller).to have_received(:remember_me).with(user)
      end

      it 'signs in the user' do
        expect(controller).to have_received(:sign_in).with(user, event: :authentication)
      end
    end

    context 'when user not persisted' do
      let(:user) { build(:user) }

      before do
        allow(User).to receive(:from_omniauth).with(auth).and_return(user)
        request.env['omniauth.auth'] = auth
        allow(controller).to receive(:redirect_to) do |arg|
          controller.instance_variable_set(:@redirect_target, arg)
        end
        get :google_oauth2, as: :json
      end

      it 'stores omniauth data in session' do
        expect(session['devise.google_data']).to eq(auth)
      end

      it 'redirects to registration' do
        expect(controller.instance_variable_get(:@redirect_target)).to eq(new_user_registration_url)
      end
    end
  end

  describe 'redirect_url' do
    let(:transcript) { create(:transcript) }

    context 'when state present' do
      let(:expected) do
        institution_transcript_path(
          institution: transcript.collection.institution.slug,
          collection: transcript.collection.uid,
          id: transcript.uid
        )
      end

      before do
        allow(User).to receive(:from_omniauth).and_return(create(:user))
        allow(controller).to receive(:remember_me)
        allow(controller).to receive(:sign_in)
        allow(controller).to receive(:redirect_to) do |arg|
          controller.instance_variable_set(:@redirect_target, arg)
        end

        get :facebook, params: { state: transcript.uid }, as: :json
      end

      it 'redirects to transcript path' do
        expect(controller.instance_variable_get(:@redirect_target)).to eq(expected)
      end
    end

    context 'when state missing' do
      before do
        allow(User).to receive(:from_omniauth).and_return(create(:user))
        allow(controller).to receive(:remember_me)
        allow(controller).to receive(:sign_in)
        allow(controller).to receive(:redirect_to) do |arg|
          controller.instance_variable_set(:@redirect_target, arg)
        end

        get :facebook, as: :json
      end

      it 'redirects to root' do
        expect(controller.instance_variable_get(:@redirect_target)).to eq('/')
      end
    end

    shared_examples 'redirects based on state' do |action|
      context 'when state present' do
        let(:expected) do
          institution_transcript_path(
            institution: transcript.collection.institution.slug,
            collection: transcript.collection.uid,
            id: transcript.uid
          )
        end

        before do
          allow(User).to receive(:from_omniauth).and_return(create(:user))
          allow(controller).to receive(:remember_me)
          allow(controller).to receive(:sign_in)
          allow(controller).to receive(:redirect_to) do |arg|
            controller.instance_variable_set(:@redirect_target, arg)
          end

          get action, params: { state: transcript.uid }, as: :json
        end

        it 'redirects to transcript path' do
          expect(controller.instance_variable_get(:@redirect_target)).to eq(expected)
        end
      end

      context 'when state missing' do
        before do
          allow(User).to receive(:from_omniauth).and_return(create(:user))
          allow(controller).to receive(:remember_me)
          allow(controller).to receive(:sign_in)
          allow(controller).to receive(:redirect_to) do |arg|
            controller.instance_variable_set(:@redirect_target, arg)
          end

          get action, as: :json
        end

        it 'redirects to root' do
          expect(controller.instance_variable_get(:@redirect_target)).to eq('/')
        end
      end
    end

    it_behaves_like 'redirects based on state', :facebook
    it_behaves_like 'redirects based on state', :google_oauth2
  end
end
