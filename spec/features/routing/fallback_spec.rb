# frozen_string_literal: true

require 'rails_helper'

# config/routes.rb ends with `match '*path' => 'institutions#index'`, so every
# route declared above it — the ALB health check and the Devise-gated Sidekiq
# mount — has to keep winning over the catch-all, and the catch-all has to keep
# serving institution pages rather than turning every unnamed path into an error.
RSpec.feature 'Routing fallback' do
  describe 'the load balancer health check' do
    scenario 'is routed to the built-in health controller' do
      expect(Rails.application.routes.recognize_path('/health'))
        .to include(controller: 'rails/health', action: 'show')
    end

    scenario 'answers the load balancer without authentication', :aggregate_failures do
      visit '/health'

      # The ECS target group only takes a bare 200 with a body; the green page is
      # Rails::HealthController's "up" body (its "down" body is red and a 500).
      expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to include('text/html')
      expect(page.body).to include('background-color: green')
    end
  end

  describe 'the Sidekiq admin mount' do
    scenario 'redirects an anonymous visitor to the sign-in page', :aggregate_failures do
      visit '/sidekiq'

      expect(page).to have_current_path('/users/sign_in')
      expect(page).to have_field(SignInPage::EMAIL_FIELD)
    end

    scenario 'keeps the dashboard away from a signed-in non-admin', :aggregate_failures do
      sign_in_as(:user)

      visit '/sidekiq'

      expect(page).to have_css('.exception[data-status="404"]')
      expect(page).not_to have_css('.dashboard')
    end

    scenario 'renders the dashboard for an admin', :aggregate_failures do
      sign_in_as(:admin)

      visit '/sidekiq'

      expect(page.status_code).to eq(200)
      expect(page).to have_css('.dashboard')
    end

    scenario 'renders the queue table for an admin', :aggregate_failures do
      sign_in_as(:admin)

      visit '/sidekiq/queues'

      expect(page.status_code).to eq(200)
      expect(page).to have_css('table.queues')
    end
  end

  describe 'a path with no named route' do
    scenario 'is served by InstitutionsController#index', :aggregate_failures do
      expect(Rails.application.routes.recognize_path('/any-institution'))
        .to include(controller: 'institutions', action: 'index')
      expect(Rails.application.routes.recognize_path('/any-institution/any-collection'))
        .to include(controller: 'institutions', action: 'index')
    end

    scenario 'renders the institution page for a known slug', :aggregate_failures do
      world = build_content_world
      institution_page = InstitutionPage.new.visit_path(world.institution.slug)

      expect(page.status_code).to eq(200)
      expect(institution_page.institution_name).to eq(world.institution.name)
    end

    scenario 'renders the not-found page, not a server error, for an unknown slug', :aggregate_failures do
      visit '/no-such-institution/no-such-collection'

      expect(page.status_code).to eq(404)
      expect(page).to have_css('.exception[data-status="404"]')
      expect(page).not_to have_text('Error 500')
    end
  end
end
