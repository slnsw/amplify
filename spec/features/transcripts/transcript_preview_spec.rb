require 'rails_helper'

RSpec.feature 'Transcript Preview' do
  let!(:transcript) { create(:transcript, published_at: nil) }
  let!(:my_page) { create(:page, page_type: 'instructions') }
  let!(:public_page) { create(:public_page, page: my_page) }

  describe 'can see an unpublished transcript preview page', js: true do
    context 'when an admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in admin
        visit transcript_path(transcript, preview: true)
      end

      it 'shows the preview page' do
        expect(page).to have_text(transcript.title)
        expect(page).to have_current_path(
          institution_transcript_path(transcript.collection.institution.slug, transcript.collection.uid, transcript, preview: true)
        )
      end
    end

    context 'when a content editor' do
      let(:content_editor) { create(:user, :content_editor) }

      before do
        sign_in content_editor
        visit transcript_path(transcript, preview: true)
      end

      it 'shows the preview page' do
        expect(page).to have_text(transcript.title)
        expect(page).to have_current_path(
          institution_transcript_path(transcript.collection.institution.slug, transcript.collection.uid, transcript, preview: true)
        )
      end
    end

    context 'when a normal user' do
      let(:user) { create(:user) }

      before do
        sign_in user
        visit transcript_path(transcript, preview: true)
      end

      it "doesn't show the preview of the unpublished transcript" do
        expect(page).not_to have_text(transcript.title)
        expect(page).not_to have_text('Error 500 Internal server error')
        expect(page).to have_current_path(transcript_path(transcript, preview: true))
      end
    end
  end
end
