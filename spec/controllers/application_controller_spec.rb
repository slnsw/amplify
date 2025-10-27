# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    # Anonymous controller inherits all before_actions from ApplicationController
    def index
      render plain: 'OK'
    end
  end

  describe 'callbacks' do
    before do
      allow(controller).to receive(:set_paper_trail_whodunnit).and_call_original
      allow(controller).to receive(:touch_session).and_call_original
      allow(controller).to receive(:load_user_edits).and_call_original
      allow(controller).to receive(:load_footer).and_call_original
      allow(controller).to receive(:set_ie_headers).and_call_original
      allow(controller).to receive(:load_app_config).and_call_original
      allow(controller).to receive(:set_pagination_params).and_call_original
      allow(TranscriptEdit).to receive(:getByUser).and_call_original
    end

    describe '#set_paper_trail_whodunnit' do
      it 'calls set_paper_trail_whodunnit' do
        get :index
        expect(controller).to have_received(:set_paper_trail_whodunnit)
      end
    end

    describe '#touch_session' do
      it 'sets session[:touched] to 1' do
        get :index
        expect(session[:touched]).to eq(1)
      end
    end

    describe '#load_user_edits' do
      context 'when current_user is not present' do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
        end

        it 'sets current_user.total_edits to the count of edits if current_user is present' do
          get :index
          expect(TranscriptEdit).not_to have_received(:getByUser)
        end
      end

      context 'when current_user is present' do
        let(:user) { build_stubbed(:user, id: 1, total_edits: nil) }

        before do
          allow(controller).to receive(:current_user).and_return(user)
          create_list(:transcript_edit, 3, user_id: user.id)
        end

        it 'sets current_user.total_edits to the count of edits if current_user is present' do
          get :index
          expect(user.total_edits).to eq 3
        end
      end

      context 'when current_user.total_edits is already set' do
        before do
          user = build_stubbed(:user, id: 1, total_edits: 3)
          allow(controller).to receive(:current_user).and_return(user)
          create_list(:transcript_edit, 3, user_id: user.id)
        end

        it 'sets current_user.total_edits to the count of edits if current_user is present' do
          get :index
          expect(TranscriptEdit).not_to have_received(:getByUser)
        end
      end
    end

    describe '#load_footer' do
      it 'assigns to `@global_content`' do
        allow(Site).to receive(:new).and_return(instance_double(Site, footer_content: 1, footer_links: 2))

        get :index
        expect(assigns[:global_content]).to(eq({ footer_content: 1, footer_links: 2 }))
      end
    end

    describe '#set_ie_headers' do
      it 'sets `X-UA-Compatible` response header' do
        get :index
        expect(response.headers['X-UA-Compatible']).to eq('IE=edge')
      end
    end

    describe '#load_app_config' do
      it 'assigns to `@app_config`' do
        get :index
        expect(assigns(:app_config)).to eq AppConfig.instance
      end
    end

    describe '#set_pagination_params' do
      it 'sets the default pagination params' do
        get :index
        expect(controller.params.permit!.to_h).to include(page: 1, per_page: 50)
      end
    end
  end

  describe '#facebook_app_id' do
    before do
      allow(ENV).to receive(:fetch).with('FACEBOOK_APP_ID', nil).and_return('test_facebook_app_id')
    end

    it 'returns the FACEBOOK_APP_ID env variable' do
      expect(controller.facebook_app_id).to eq('test_facebook_app_id')
    end
  end

  describe '#frontend_config' do
    context 'when frontend config is present' do
      before do
        allow(Rails.application).to receive(:config_for).with(:frontend).and_return({ key1: 'value1', key2: 'value2' })
      end

      it 'returns the frontend config as a hash' do
        expect(controller.frontend_config).to eq({ key1: 'value1', key2: 'value2' })
      end
    end

    context 'when frontend config is blank' do
      before do
        allow(Rails.application).to receive(:config_for).with(:frontend).and_return(nil)
      end

      it 'returns an empty hash' do
        expect(controller.frontend_config).to eq({})
      end
    end
  end

  describe '#project_key' do
    before do
      allow(ENV).to receive(:fetch).with('PROJECT_ID', nil).and_return('test_project_id')
    end

    it 'returns the PROJECT_ID env variable' do
      expect(controller.project_key).to eq('test_project_id')
    end
  end
end
