# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe '#authenticate' do
    context 'when requested format is json' do
      context 'when current_user is present' do
        let(:user) { create(:user) }

        before do
          allow(controller).to receive(:current_user).and_return(user)
          post :authenticate, as: :json
        end

        it 'assigns @user to current_user' do
          expect(assigns(:user)).to eq user
        end

        it 'responds with json content type' do
          expect(response.content_type).to include 'application/json'
        end
      end

      context 'when current_user is not present' do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
          post :authenticate, as: :json
        end

        it 'assigns a new User' do
          expect(assigns(:user)).to be_a_new(User)
        end

        it 'responds with json content type' do
          expect(response.content_type).to include 'application/json'
        end
      end
    end

    context 'when requested format is html' do
      it 'raises UnknownFormat when current_user is present' do
        allow(controller).to receive(:current_user).and_return(build_stubbed(:user))
        expect { post :authenticate }.to raise_error(ActionController::UnknownFormat)
      end

      it 'raises UnknownFormat when current_user is not present' do
        allow(controller).to receive(:current_user).and_return(nil)
        expect { post :authenticate }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
