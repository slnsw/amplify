# frozen_string_literal: true

require 'rails_helper'

# /admin/app_configs/:id/edit edits the single AppConfig the public site reads
# (ApplicationController#load_app_config -> AppConfig.instance). There is no
# index: the form is reached from the side pane's "Site Config" entry.
RSpec.feature 'Site configuration' do
  let(:config) { AdminAppConfigPage.new }

  describe 'as an admin', :js do
    before { sign_in_as(:admin) }

    scenario 'renders the form from the side pane', :aggregate_failures do
      config.visit_form

      expect(page).to have_text('Show theme')
      expect(page).to have_field('app_config_main_title')
    end

    scenario 'persists an updated value across a reload', :aggregate_failures do
      config.visit_form.update_main_title('Listen, transcribe, enrich')

      expect(config.main_title).to eq('Listen, transcribe, enrich')
      page.refresh
      expect(config.main_title).to eq('Listen, transcribe, enrich')
    end
  end
end
