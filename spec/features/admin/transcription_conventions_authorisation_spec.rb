# frozen_string_literal: true

require 'rails_helper'

# /admin/institutions/:institution_id/transcription_conventions
# (app/controllers/admin/transcription_conventions_controller.rb) edits the
# conventions every transcript of an institution shows its editors, so it is
# staff-only like the rest of the admin CMS. Create, update and destroy are each
# checked: every one of them writes.
RSpec.feature 'Transcription convention authorisation', driver: :conventions_no_redirects do
  # rack_test follows redirects, so a refused request would be reported by
  # whatever the root page renders instead of by the redirect itself. The
  # refusals are asserted from the response.
  Capybara.register_driver :conventions_no_redirects do |app|
    Capybara::RackTest::Driver.new(app, follow_redirects: false)
  end

  let(:institution) { create(:institution) }
  let!(:convention) { create(:transcription_convention, institution: institution, convention_text: 'Original text') }
  let(:collection_path) { "/admin/institutions/#{institution.slug}/transcription_conventions" }
  let(:member_path) { "#{collection_path}/#{convention.id}" }
  let(:create_params) { { transcription_convention: { convention_key: 'Authorisation', convention_text: 'Created' } } }
  let(:update_params) { { transcription_convention: { convention_text: 'Changed' } } }

  shared_examples 'a refused visitor' do
    scenario 'cannot create a convention', :aggregate_failures do
      expect { page.driver.submit(:post, collection_path, create_params) }
        .not_to change(TranscriptionConvention, :count)

      expect(refusal).to eq([302, root_url])
    end

    scenario 'cannot update a convention', :aggregate_failures do
      page.driver.submit(:patch, member_path, update_params)

      expect(convention.reload.convention_text).to eq('Original text')
      expect(refusal).to eq([302, root_url])
    end

    scenario 'cannot destroy a convention', :aggregate_failures do
      expect { page.driver.submit(:delete, member_path, {}) }.not_to change(TranscriptionConvention, :count)

      expect(refusal).to eq([302, root_url])
    end
  end

  describe 'an anonymous visitor' do
    it_behaves_like 'a refused visitor'
  end

  describe 'a signed-in non-staff user' do
    before { sign_in_as(:user) }

    it_behaves_like 'a refused visitor'
  end

  # Proves the filter lets staff through, so the refusals above come from the
  # authorisation check rather than from a dead endpoint.
  describe 'staff' do
    before { sign_in_as(:admin) }

    scenario 'creates a convention' do
      expect { page.driver.submit(:post, collection_path, create_params) }
        .to change(TranscriptionConvention, :count).by(1)
    end

    scenario 'updates a convention' do
      page.driver.submit(:patch, member_path, update_params)

      expect(convention.reload.convention_text).to eq('Changed')
    end

    scenario 'destroys a convention' do
      expect { page.driver.submit(:delete, member_path, {}) }.to change(TranscriptionConvention, :count).by(-1)
    end
  end

  private

  # The status and Location of a refusal, which this driver does not follow.
  def refusal = [page.status_code, page.response_headers['Location']]
end
