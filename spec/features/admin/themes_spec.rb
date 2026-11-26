# frozen_string_literal: true

require 'rails_helper'

# /admin/themes manages the collection themes a CMS admin tags collections with
# (app/controllers/admin/themes_controller.rb). A theme carries only a name.
RSpec.feature 'CMS themes' do
  let(:themes) { AdminThemesPage.new }

  describe 'as an admin', :js do
    before do
      create(:theme, name: 'Environment')
      sign_in_as(:admin)
    end

    scenario 'lists the themes' do
      themes.visit_index
      expect(themes.names).to include('Environment')
    end

    scenario 'renders the new theme form', :aggregate_failures do
      themes.visit_index.open_new

      expect(page).to have_text('New Theme')
      expect(page).to have_field('theme_name')
    end

    scenario 'renders the edit form of an existing theme', :aggregate_failures do
      themes.visit_index.edit('Environment')

      expect(page).to have_text('Editing Theme')
      expect(page).to have_field('theme_name', with: 'Environment')
    end

    scenario 'persists a created theme so the list still shows it after a reload', :aggregate_failures do
      themes.create('Migration')

      expect(themes.names).to include('Migration')
      page.refresh
      expect(themes.names).to include('Migration')
    end

    scenario 'persists a renamed theme so the list still shows it after a reload', :aggregate_failures do
      themes.visit_index.rename(from: 'Environment', to: 'Landscape')

      expect(themes.names).to include('Landscape')
      page.refresh
      expect(themes.names).to include('Landscape')
    end
  end
end
