require 'rails_helper'

RSpec.describe Admin::AppConfigsController, type: :controller do
  render_views

  let(:user) { create(:user, :admin, email: "user@email.com", password: "password") }
  let!(:config) { AppConfig.instance }

  before { sign_in user }

  describe '#edit' do
    it 'can view edit page' do
      get :edit, params: { id: config.id }

      page = response.body

      expect(page).to have_content('Show theme')
      expect(page).to have_content('Show institutions')
      expect(page).to have_content('Main title')
      expect(page).to have_content('Intro title')
      expect(page).to have_content('Intro text')
      expect(page).to have_content('Hero image')
      expect(page).to include('Save')
    end
  end

  describe '#update' do
    it 'updates app config' do
      params = {
        id: config.id,
        app_config: {
          show_theme: true,
          show_institutions: true,
          main_title: 'Any title possible',
          image: nil,
          intro_title: 'Any intro title',
          intro_text: 'Any intro text'
        }
      }

      put :update, params: params
      expect(response.body).to have_content('redirected')

      config.reload
      expect(config.show_theme).to be_truthy
      expect(config.show_institutions).to be_truthy
      expect(config.main_title).to eq 'Any title possible'
      expect(config.intro_title).to eq 'Any intro title'
      expect(config.intro_text).to eq 'Any intro text'
    end
  end
end
