# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Institutions::GuidsController, type: :controller do
  describe '#index' do
    let!(:institution_one) { create(:institution, slug: 'one', guid: 'g1') }
    let!(:institution_two) { create(:institution, slug: 'two', guid: 'g2') }
    let(:secret) { 's3cr3t' }

    before do
      allow(ENV).to receive(:[]).with('LOOKER_STUDIO_EXTERNAL_SECRET').and_return(secret)
    end

    context 'when authorized' do
      before do
        # ensure the institutions are created
        institution_one
        institution_two
        request.headers['Authorization'] = "Bearer #{secret}"
        get :index, as: :json
      end

      it 'responds ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes institution one UID/GUID' do
        body = response.parsed_body
        expect(body).to include({ 'UID' => 'one', 'GUID' => 'g1' })
      end

      it 'includes institution two UID/GUID' do
        body = response.parsed_body
        expect(body).to include({ 'UID' => 'two', 'GUID' => 'g2' })
      end
    end

    context 'when unauthorized' do
      before do
        request.headers['Authorization'] = 'Bearer wrong'
        get :index, as: :json
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when no Authorization header present' do
      before do
        get :index, as: :json
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
