# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe '#authenticate' do
    context 'when current_user is present' do
      let(:user) { build_stubbed(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        post :authenticate
      end

      it 'assigns @user to current_user' do
        expect(assigns(:user)).to eq user
      end
    end

    context 'when current_user is not present' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        post :authenticate
      end

      it 'assigns a new User' do
        expect(assigns(:user)).to be_a_new(User)
      end
    end
  end
end
