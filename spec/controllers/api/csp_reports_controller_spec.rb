# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CspReportsController, type: :controller do
  describe '#create' do
    let(:payload) { { 'csp-report' => { 'blocked-uri' => 'http://example.com' } } }

    before do
      allow(CSP_LOGGER).to receive(:info)
      post :create, body: payload.to_json, as: :json
    end

    it 'logs the raw request body' do
      expect(CSP_LOGGER).to have_received(:info).with(/CSP Violation:/)
    end

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end
  end
end
