# frozen_string_literal: true

RSpec.describe IndexTemplate, type: :controller do
  controller(ApplicationController) do
    include IndexTemplate

    def index
      @file = environment_file('template')
      @config = @app_config
      render plain: 'ok'
    end
  end

  before do
    allow(ENV).to receive(:fetch).with('PROJECT_ID', nil).and_return('test-project')
    allow(ENV).to receive(:fetch).with('APP_CONFIG', nil).and_return('test_config')
  end

  describe '#environment_file' do
    it 'constructs file path with PROJECT_ID' do
      get :index
      expect(assigns(:file)).to include('public/test-project/template.html')
    end

    context 'when environment-specific file exists' do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it 'uses environment-specific file' do
        get :index
        expect(assigns(:file)).to include("template.#{Rails.env.downcase}.html")
      end
    end

    context 'when environment-specific file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'uses default file' do
        get :index
        expect(assigns(:file)).to include('template.html')
        expect(assigns(:file)).not_to include("template.#{Rails.env.downcase}.html")
      end
    end
  end

  describe '#environment_app_config' do
    it 'converts APP_CONFIG to JSON' do
      get :index
      expect(assigns(:config)).to eq('"test_config"')
    end
  end
end
