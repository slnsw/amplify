# frozen_string_literal: true

require 'rails_helper'

# /admin/institutions lists every institution and its form saves the columns the
# list echoes back (app/views/admin/institutions/). The transcription conventions
# nested under one institution are covered here too, since they are only
# reachable from that list.
RSpec.feature 'Institution Page' do
  let(:admin) { create(:user, :admin) }
  let(:institutions) { AdminInstitutionPage.new }
  let!(:first_institution) { create(:institution, name: 'First institution') }
  let!(:second_institution) { create(:institution, name: 'Second institution') }

  describe 'the Institution page as an admin', :js do
    before { sign_in admin }

    scenario 'lists every institution', :smoke do
      institutions.visit_index
      expect(institutions.names).to include(first_institution.name, second_institution.name)
    end

    scenario 'renders the new institution form', :aggregate_failures do
      page.visit('/admin/institutions/new')
      expect(page).to have_text('New Institution')
      expect(page).to have_text('Custom footer links')
    end

    scenario 'renders the edit form with the stored footer links', :aggregate_failures do
      create(:institution_link, institution: first_institution, title: 'Original Link', url: 'http://original.com')

      institutions.visit_index.edit(first_institution.name)

      expect(page).to have_text('Editing Institution')
      expect(institutions.footer_link_titles).to include('Original Link')
    end

    # The list is the page that echoes the edited columns, so reopening it is
    # what proves the update reached the database.
    scenario 'persists an edited url so the list still shows it after a reload', :aggregate_failures do
      institutions.visit_index.edit(first_institution.name).fill('institution_url' => 'http://updated.example.com/').save

      expect(institutions.url_of(first_institution.name)).to eq('http://updated.example.com/')
      page.refresh
      expect(institutions.url_of(first_institution.name)).to eq('http://updated.example.com/')
    end

    # The UID is what the edit form is re-fetched by, so saving it also proves
    # the footer links submitted with it were written.
    scenario 'persists the UID and footer links an admin submits' do
      institutions.visit_index.edit(first_institution.name)
                  .fill('institution_slug' => 'firstinstitution')
                  .fill_first_footer_link(title: 'My Link', url: 'http://www.mylink.com').save

      institutions.edit('firstinstitution')
      expect(institutions.footer_link_titles).to include('My Link')
    end
  end

  describe 'the transcription conventions of an institution as an admin', :js do
    # `Institution#after_create` seeds the eight defaults, so a built key is a
    # new row rather than a redisplay of the seed data.
    before do
      sign_in admin
      institutions.visit_conventions(first_institution)
    end

    scenario 'creates a convention the list still shows after a reload', :aggregate_failures do
      institutions.create_convention(key: 'Punctuation', text: 'Use full stops', example: '“Hello.”')

      expect(institutions.convention_keys).to include('Punctuation')
      page.refresh
      expect(institutions.convention_keys).to include('Punctuation')
    end

    scenario 'persists an edited convention across a reload', :aggregate_failures do
      institutions.update_convention('Language', text: 'English (Australian) spelling')

      expect(institutions.convention_text_for('Language')).to eq('English (Australian) spelling')
      page.refresh
      expect(institutions.convention_text_for('Language')).to eq('English (Australian) spelling')
    end
  end
end
