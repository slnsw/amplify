# frozen_string_literal: true

require 'rails_helper'

# Browsers POST `application/csp-report` documents to the URI configured in
# config/initializers/content_security_policy.rb. Such a request carries no CSRF
# token — a browser has none to send — so the endpoint has to answer it anyway;
# a lost CSRF skip would surface here as a 422.
RSpec.feature 'CSP violation reports' do
  let(:report) do
    {
      'csp-report' => {
        'document-uri' => 'http://www.example.com/transcripts/example',
        'violated-directive' => 'script-src',
        'effective-directive' => 'script-src',
        'blocked-uri' => 'http://cdn.example.com/tracker.js',
        'status-code' => 200
      }
    }
  end

  scenario 'accepts a report posted as application/csp-report' do
    post_report(report)

    expect(page.status_code).to eq(200)
  end

  def post_report(body)
    page.driver.browser.submit(:post, '/csp-violation-report-endpoint', body.to_json,
                               content_type: 'application/csp-report')
  end
end
