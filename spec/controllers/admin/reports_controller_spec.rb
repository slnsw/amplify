# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
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
  end

  describe '#users' do
    context 'when requested format is html' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        create(:user)
        create(:institution)
        get :users
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @users' do
        expect(assigns(:users)).to be_an(Array)
      end
    end

    context 'when requested format is csv' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :users, format: :csv
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'returns csv content type' do
        expect(response.content_type).to include('text/csv')
      end
    end
  end
end
