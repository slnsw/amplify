# frozen_string_literal: true

require 'rails_helper'

# /admin/site_alerts publishes the banners every public page renders through
# `shared/_site_alerts` (app/views/layouts/application_v2.html.erb), so a created
# alert is checked on the public home page.
RSpec.feature 'CMS site alerts' do
  let(:alerts) { AdminSiteAlertsPage.new }
  let(:world) { build_content_world }
  let(:machine_name) { 'read-only-notice' }
  let(:message) { 'Amplify is read only today' }

  describe 'as an admin', :js do
    before do
      world
      sign_in_as(:admin)
    end

    scenario 'renders the new alert form', :aggregate_failures do
      alerts.visit_index.open_new

      expect(page).to have_text('New Page')
      expect(page).to have_field('site_alert_machine_name')
    end

    scenario 'renders the edit form of an existing alert', :aggregate_failures do
      SiteAlert.create!(machine_name: 'maintenance', level: 'warning', message: 'Scheduled maintenance',
                        published: true)

      alerts.visit_index.edit('Scheduled maintenance')

      expect(page).to have_text('Editing Page')
      expect(page).to have_field('site_alert_machine_name', with: 'maintenance')
    end

    scenario 'lists the created alert', :aggregate_failures do
      alerts.create(machine_name: machine_name, message: message)

      expect(alerts.levels).to eq(['Warning'])
      # The list renders the stored markup rather than the sanitized body.
      expect(alerts.messages.first).to include(message)
    end

    scenario 'shows a created alert on the public home page', :aggregate_failures do
      alerts.create(machine_name: machine_name, message: message)
      page.visit('/')

      expect(page).to have_css("#site-alert--#{machine_name}", text: message)
      page.refresh
      expect(page).to have_css("#site-alert--#{machine_name}", text: message)
    end
  end
end
