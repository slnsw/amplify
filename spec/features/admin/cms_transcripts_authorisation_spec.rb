# frozen_string_literal: true

require 'rails_helper'

# /admin/cms/transcripts (app/controllers/admin/cms/transcripts_controller.rb)
# manages the items of a collection, so it is staff-only like the sibling
# collections controller. Both the create form and the bulk delete are checked:
# one writes a record, the other destroys existing ones.
RSpec.feature 'CMS transcript authorisation' do
  # rack_test follows redirects, so a refused request would be reported by
  # whatever the root page renders instead of by the redirect itself. The
  # refusals are asserted from the response.
  Capybara.register_driver :cms_transcripts_no_redirects do |app|
    Capybara::RackTest::Driver.new(app, follow_redirects: false)
  end

  let(:world) { build_content_world }
  let(:new_item_uid) { 'authorisation-item' }
  let(:new_item_path) { '/admin/cms/transcripts' }
  let(:bulk_path) { '/admin/cms/transcripts/update_multiple.js' }
  let(:new_item_params) do
    {
      transcript: {
        uid: new_item_uid,
        title: 'Authorisation item',
        collection_id: world.collection.id,
        speakers: '',
        transcript_type: 'manual'
      }
    }
  end
  let(:bulk_delete_params) do
    {
      collection_uid: world.collection.uid,
      transcript_ids: [world.transcript.uid],
      commit: 'delete'
    }
  end

  describe 'an anonymous visitor' do
    scenario 'cannot create an item', :aggregate_failures, driver: :cms_transcripts_no_redirects do
      world
      expect { page.driver.submit(:post, new_item_path, new_item_params) }.not_to change(Transcript, :count)

      expect(refusal).to eq([302, root_url])
    end

    scenario 'cannot bulk delete items', :aggregate_failures, driver: :cms_transcripts_no_redirects do
      world
      expect { page.driver.submit(:put, bulk_path, bulk_delete_params) }.not_to change(Transcript, :count)

      expect(refusal).to eq([302, root_url])
    end
  end

  describe 'a signed-in non-staff user' do
    scenario 'cannot create an item', :aggregate_failures, driver: :cms_transcripts_no_redirects do
      world
      sign_in_as(:user)
      expect { page.driver.submit(:post, new_item_path, new_item_params) }.not_to change(Transcript, :count)

      expect(refusal).to eq([302, root_url])
    end

    scenario 'cannot bulk delete items', :aggregate_failures, driver: :cms_transcripts_no_redirects do
      world
      sign_in_as(:user)
      expect { page.driver.submit(:put, bulk_path, bulk_delete_params) }.not_to change(Transcript, :count)

      expect(refusal).to eq([302, root_url])
    end
  end

  # Proves the filter lets staff through, so the refusals above come from the
  # authorisation check rather than from a dead endpoint.
  describe 'staff' do
    scenario 'creates an item through the form', :aggregate_failures do
      world
      sign_in_as(:admin)
      expect { create_item_through_form }.to change(Transcript, :count).by(1)

      expect(page).to have_current_path("/admin/cms/collections/#{world.collection.uid}")
      expect(Transcript.find_by(uid: new_item_uid).title).to eq('Authorisation item')
    end
  end

  private

  # The status and Location of a refusal, which this driver does not follow.
  def refusal = [page.status_code, page.response_headers['Location']]

  def create_item_through_form
    page.visit("/admin/cms/transcripts/new?collection_uid=#{world.collection.uid}")
    page.fill_in('transcript_uid', with: new_item_uid)
    page.fill_in('transcript_title', with: 'Authorisation item')
    page.choose('transcript_transcript_type_manual')
    page.click_button('Save Item')
  end
end
