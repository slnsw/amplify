# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AppConfigsController, type: :controller do
  describe '#edit' do
    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        get :edit, params: { id: 1 }
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '#update' do
    let(:app_config_params) do
      {
        id: 1,
        app_config: {
          main_title: 'New Title',
          intro_text: 'New intro text'
        }
      }
    end

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      before do
        sign_in user
        patch :update, params: app_config_params
      end

      it 'redirects to edit path on successful update' do
        expect(response).to redirect_to(edit_admin_app_config_path(assigns(:app_config).id))
      end
    end

    context 'when update fails' do
      let(:user) { create(:user, :admin) }
      let(:app_config_instance) { AppConfig.instance }

      before do
        allow(AppConfig).to receive(:instance).and_return(app_config_instance)
        allow(app_config_instance).to receive(:update).and_return(false)
        sign_in user
        patch :update, params: app_config_params
      end

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end
end
