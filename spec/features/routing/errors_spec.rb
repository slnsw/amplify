# frozen_string_literal: true

require 'rails_helper'

# Requests that cannot be served get the app's own error page (the
# exception_handler middleware configured in config/application.rb); a link to a
# record that has since been deleted is the everyday case.
RSpec.feature 'Error surfaces' do
  describe 'a transcript deleted after a visitor was given its link' do
    let(:world) { build_content_world }
    let(:path) { institution_transcript_path(world.institution.slug, world.collection.uid, world.transcript) }

    # Known defect 5 (docs/testing.md): TranscriptService.find_by_uid falls back
    # to `Transcript.new`, so an anonymous visitor gets an empty 200 editor shell
    # where a content editor gets the 404 page. That shell is the defect, so it is
    # not asserted here; the behaviour under test is only that the missing record
    # does not become a server error.
    scenario 'is not a server error for an anonymous visitor' do
      visit_transcript_then_delete_it

      expect(page.status_code).not_to be_between(500, 599)
    end

    scenario 'renders the not-found page for a content editor', :aggregate_failures do
      sign_in_as(:content_editor)

      visit_transcript_then_delete_it

      expect(page.status_code).to eq(404)
      expect(page).to have_css('.exception[data-status="404"]')
      expect(page).not_to have_text('Error 500')
    end
  end

  # The path has to answer 200 while the record exists, otherwise a 404 after the
  # deletion would prove nothing.
  def visit_transcript_then_delete_it
    visit path
    expect(page.status_code).to eq(200)

    world.transcript.destroy!
    visit path
  end
end
