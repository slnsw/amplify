require 'rails_helper'

RSpec.describe Admin::StatsController, type: :controller do
  render_views

  let(:user) { create(:user, :admin) }
  let!(:flag) do
    institution = create(:institution)
    collection = create(:collection, institution: institution)
    transcript = create(:transcript, collection: collection)
    flag = create(:flag, transcript_id: transcript.id)

    flag.decorate
  end
  let(:page) { response.body }

  before { sign_in user }

  describe '#index' do
    before { get :index }

    it 'renders Unresolved Flags' do
      expect(page).to have_content('Unresolved Flags')
      expect(page).to have_content(flag.institution&.name)
      expect(page).to have_content(flag.flag_type.label )
      expect(page).to have_content(flag.text)
      transcript_line = flag.transcript_line
      transcript = transcript_line.transcript.decorate
      expect(page).to have_content(transcript.title)
    end

    it 'renders Institution edits section' do
      expect(page).to have_content('Institution edits')
      transcript_line = flag.transcript_line
      expect(page).to include(transcript_line.transcript.collection.institution.name)
    end

    it 'renders Site-wide edits section' do
      expect(page).to have_content('Site-wide edits')
    end

    it 'renders Site-wide registrations section' do
      expect(page).to have_content('Site-wide registrations')
    end
  end
end
