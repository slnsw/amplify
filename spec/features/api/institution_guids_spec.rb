# frozen_string_literal: true

require 'rails_helper'

# Looker Studio reads the institution slugs and guids from this endpoint, guarded
# by a bearer secret (app/controllers/api/institutions/guids_controller.rb).
RSpec.feature 'Institution guids API' do
  let(:secret) { 'feature-spec-looker-secret' }
  let(:institution) { build_content_world.institution }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('LOOKER_STUDIO_EXTERNAL_SECRET').and_return(secret)
  end

  scenario 'returns each institution slug as UID and its guid as GUID', :aggregate_failures do
    institution.update!(guid: 'guid-of-the-institution')

    get_guids("Bearer #{secret}")

    expect(page.status_code).to eq(200)
    expect(page.response_headers['Content-Type']).to include('application/json')
    expect(parsed_guids).to include('UID' => institution.slug, 'GUID' => 'guid-of-the-institution')
  end

  # The controller answers this before it queries, so no institution is needed.
  scenario 'rejects a request without the bearer secret' do
    get_guids(nil)

    expect(page.status_code).to eq(401)
  end

  def get_guids(authorization)
    page.driver.header('Authorization', authorization)
    visit '/api/institutions/guids'
  end

  def parsed_guids
    JSON.parse(page.body)
  end
end
