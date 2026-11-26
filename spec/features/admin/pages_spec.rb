# frozen_string_literal: true

require 'rails_helper'

# /admin/pages manages the CMS pages the public site renders at /page/:page_type
# (app/controllers/admin/pages_controller.rb). The body is a Summernote editor,
# so the body is typed into the editor rather than the hidden textarea.
RSpec.feature 'CMS pages' do
  let(:pages) { AdminPagesPage.new }

  describe 'as an admin', :js do
    before { sign_in_as(:admin) }

    scenario 'lists the existing pages' do
      create(:page, page_type: 'faq', content: 'Frequently asked questions')

      pages.visit_index
      expect(pages.page_types).to eq(['Faq'])
    end

    scenario 'renders the new page form', :aggregate_failures do
      pages.visit_index.open_new

      expect(page).to have_text('New Page')
      expect(page).to have_field('page_page_type')
    end

    scenario 'renders the edit form of an existing page', :aggregate_failures do
      create(:page, page_type: 'about', content: 'About the project')

      pages.visit_index.edit('About')

      expect(page).to have_text('Editing Page')
      expect(pages.content).to eq('About the project')
    end

    scenario 'persists a created page body so the edit form shows it after a reload', :aggregate_failures do
      pages.create(page_type: 'collecting-stories', body: 'Collecting stories records oral histories')
      pages.edit('Collecting-stories')

      expect(pages.content).to include('Collecting stories records oral histories')
      page.refresh
      expect(pages.content).to include('Collecting stories records oral histories')
    end

    scenario 'deletes a page the list no longer shows after a reload', :aggregate_failures do
      create(:page, page_type: 'faq', content: 'Frequently asked questions')

      pages.visit_index.delete('Faq')

      expect(pages.page_types).to be_empty
      page.refresh
      expect(pages.page_types).to be_empty
    end
  end
end
