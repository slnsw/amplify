require "rails_helper"

RSpec.describe Api::CspReportsController, type: :controller do
  describe "POST #create" do
    it "logs the CSP report and returns ok" do
      expect(CSP_LOGGER).to receive(:info).with(/CSP Violation:/)
      request.headers["Content-Type"] = "application/json"
      post :create, body: { "csp-report": { "document-uri": "http://example.com" } }.to_json
      expect(response).to have_http_status(:ok)
    end
  end
end
