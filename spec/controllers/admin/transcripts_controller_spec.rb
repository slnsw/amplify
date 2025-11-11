# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TranscriptsController, type: :controller do
  describe '#index' do
    context 'when requested format is json' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :index, format: :json
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @transcripts' do
        expect(assigns(:transcripts)).to eq([])
      end
    end
  end
end
