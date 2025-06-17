# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end

  let(:user) { create(:user) }

  describe '#touch_session' do
    it 'sets session[:touched] to 1' do
      get :index
      expect(session[:touched]).to eq(1)
    end
  end

  describe '#load_user_edits' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(TranscriptEdit).to receive(:getByUser).with(user.id).and_return(double(count: 42))
    end

    it 'sets current_user.total_edits if not already set' do
      user.total_edits = nil
      get :index
      expect(user.total_edits).to eq(42)
    end

    it 'does not overwrite current_user.total_edits if already set' do
      user.total_edits = 99
      get :index
      expect(user.total_edits).to eq(99)
    end
  end

  describe '#set_ie_headers' do
    it 'sets the X-UA-Compatible header' do
      get :index
      expect(response.headers['X-UA-Compatible']).to eq('IE=edge')
    end
  end

  describe '#load_footer' do
    it 'assigns @global_content with footer_content and footer_links' do
      site = instance_double(Site, footer_content: 'footer', footer_links: ['link'])
      allow(Site).to receive(:new).and_return(site)
      get :index
      expect(assigns(:global_content)).to include(:footer_content, :footer_links)
    end
  end

  describe '#load_app_config' do
    it 'assigns @app_config' do
      app_config = double('AppConfig')
      allow(AppConfig).to receive(:instance).and_return(app_config)
      get :index
      expect(assigns(:app_config)).to eq(app_config)
    end
  end

  describe '#set_pagination_params' do
    it 'sets default pagination params if not present' do
      get :index
      expect(controller.params[:page]).to eq(1)
      expect(controller.params[:per_page]).to eq(50)
    end

    it 'does not override provided pagination params' do
      get :index, params: { page: 3, per_page: 10 }
      expect(controller.params[:page]).to eq('3')
      expect(controller.params[:per_page]).to eq('10')
    end
  end

  describe '#project_key' do
    it "returns ENV['PROJECT_ID']" do
      stub_const('ENV', ENV.to_hash.merge('PROJECT_ID' => 'test_project'))
      expect(controller.project_key).to eq('test_project')
    end
  end

  describe '#frontend_config' do
    it 'returns frontend config hash' do
      allow(Rails.application).to receive(:config_for).with(:frontend).and_return({ foo: 'bar' })
      expect(controller.frontend_config).to eq({ foo: 'bar' })
    end

    it 'returns empty hash if config is blank' do
      allow(Rails.application).to receive(:config_for).with(:frontend).and_return(nil)
      expect(controller.frontend_config).to eq({})
    end
  end

  describe '#facebook_app_id' do
    it "returns ENV['FACEBOOK_APP_ID']" do
      stub_const('ENV', ENV.to_hash.merge('FACEBOOK_APP_ID' => 'fbid'))
      expect(controller.facebook_app_id).to eq('fbid')
    end
  end
end
