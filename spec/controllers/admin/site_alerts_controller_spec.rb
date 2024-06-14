require 'rails_helper'

RSpec.describe Admin::SiteAlertsController, type: :controller do
  render_views

  let(:user) { create(:user, :admin) }
  let!(:site_alert) do
    create(
      :site_alert,
      message: 'any message',
      machine_name: 'any-machine-name'
    )
  end
  let(:page) { response.body }

  before { sign_in user }

  describe '#index' do
    it 'lists site alert' do
      get :index

      expect(page).to have_content('Site Alerts')
      expect(page).to have_content('any message')
    end
  end

  describe '#new' do
    it 'renders new page' do
      get :new

      expect(page).to have_content('New Page')
      expect(page).to have_content('Level')
      expect(page).to have_content('Machine name')
      expect(page).to have_content('Message')
      expect(page).to have_content('Publish version to live site')
    end
  end

  describe '#create' do
    let(:params) do
      {
        site_alert: {
          level: 'warning',
          machine_name: 'any-dummy-machine-name',
          message: 'any dummy site alert message',
          published: true
        }
      }
    end

    it 'create a new site alert' do
      expect { post :create, params: params }.to(
        change { SiteAlert.count }.by(1)
      )
    end
  end

  describe '#edit' do
    it 'renders edit page' do
      get :edit, params: { id: site_alert.id }

      expect(page).to have_content('Editing Page')
      expect(page).to have_content('Level')
      expect(page).to have_content('Machine name')
      expect(page).to include('any-machine-name')
      expect(page).to have_content('Message')
      expect(page).to include('any message')
      expect(page).to have_content('Publish version to live site')
    end
  end

  describe '#update' do
    let(:params) do
      {
        id: site_alert.id,
        site_alert: {
          level: 'warning',
          machine_name: 'any-dummy-machine-name',
          message: 'any dummy site alert message',
          published: true
        }
      }
    end

    it 'updates site alert' do
      put :update, params: params

      site_alert.reload

      expect(site_alert.level).to eq 'warning'
      expect(site_alert.machine_name).to eq 'any-dummy-machine-name'
      expect(site_alert.message).to eq 'any dummy site alert message'
      expect(site_alert.published).to be_truthy
    end
  end

  describe '#destroy' do
    it 'destroys site alert' do
      params = { id: site_alert.id }
      expect { delete :destroy, params: params }.to(
        change { SiteAlert.count }.by(-1)
      )
    end
  end
end
