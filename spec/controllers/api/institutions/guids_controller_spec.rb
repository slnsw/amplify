# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Institutions::GuidsController, type: :controller do
  let!(:institution1) { create(:institution, slug: 'inst1', guid: 'guid-1') }
  let!(:institution2) { create(:institution, slug: 'inst2', guid: 'guid-2') }
  let(:secret) { 'test-secret' }

  before do
    stub_const('ENV', ENV.to_hash.merge('LOOKER_STUDIO_EXTERNAL_SECRET' => secret))
  end

  describe 'GET #index' do
    context 'with valid bearer token' do
      it 'returns a list of institutions with UID and GUID' do
        request.headers['Authorization'] = "Bearer #{secret}"
        get :index
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include(
          { 'UID' => 'inst1', 'GUID' => 'guid-1' },
          { 'UID' => 'inst2', 'GUID' => 'guid-2' }
        )
      end
    end

    context 'with invalid bearer token' do
      it 'returns unauthorized' do
        request.headers['Authorization'] = 'Bearer wrong'
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end

    context 'without bearer token' do
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
      end
    end
  end
end
