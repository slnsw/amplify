# frozen_string_literal: true

RSpec.describe Admin::AppConfigsController, type: :controller do
  let(:app_config) { double('AppConfig', id: 1) }
  let(:valid_params) do
    {
      app_config: {
        show_theme: true,
        show_institutions: false,
        main_title: 'Main Title',
        image: 'image.png',
        intro_title: 'Intro Title',
        intro_text: 'Intro Text'
      }
    }
  end

  before do
    allow(controller).to receive(:authorize)
    allow(AppConfig).to receive(:find).and_return(app_config)
    controller.instance_variable_set(:@app_config, app_config)
  end

  describe 'GET #edit' do
    it 'responds successfully' do
      get :edit, params: { id: app_config.id }
      expect(response).to be_successful
    end
  end

  describe 'PATCH #update' do
    context 'when update succeeds' do
      before do
        allow(app_config).to receive(:update).and_return(true)
      end

      it 'authorizes AppConfig' do
        expect(controller).to receive(:authorize).with(AppConfig)
        patch :update, params: valid_params.merge(id: app_config.id)
      end

      it 'redirects to edit_admin_app_config_path' do
        patch :update, params: valid_params.merge(id: app_config.id)
        expect(response).to redirect_to(edit_admin_app_config_path(app_config.id))
      end
    end

    context 'when update fails' do
      before do
        allow(app_config).to receive(:update).and_return(false)
      end

      it 'renders the edit template' do
        patch :update, params: valid_params.merge(id: app_config.id)
        expect(response).to render_template(:edit)
      end
    end
  end
end
