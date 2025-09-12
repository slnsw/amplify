# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    # Anonymous controller inherits all before_actions from ApplicationController
    def index
      render plain: 'OK'
    end
  end

  describe 'before_actions' do
    before do
      allow(controller).to receive(:set_paper_trail_whodunnit).and_call_original
      allow(controller).to receive(:touch_session).and_call_original
      allow(controller).to receive(:load_user_edits).and_call_original
      allow(controller).to receive(:load_footer).and_call_original
      allow(controller).to receive(:set_ie_headers).and_call_original
      allow(controller).to receive(:load_app_config).and_call_original
      allow(controller).to receive(:set_pagination_params).and_call_original
    end

    it 'calls set_paper_trail_whodunnit' do
      get :index
      expect(controller).to have_received(:set_paper_trail_whodunnit)
    end

    it 'sets session[:touched] to 1' do
      get :index
      expect(session[:touched]).to eq(1)
    end

    it 'sets current_user.total_edits to the count of edits if current_user is present' do
      user = build_stubbed(:user, id: 1, total_edits: nil)
      allow(controller).to receive(:current_user).and_return(user)
      create_list(:transcript_edit, 3, user_id: user.id)

      get :index
      expect(user.total_edits).to eq 3
    end

    it 'assigns to `@global_content`' do
      allow(Site).to receive(:new).and_return(instance_double(Site, footer_content: 1, footer_links: 2))

      get :index
      expect(assigns[:global_content]).to(eq({ footer_content: 1, footer_links: 2 }))
    end

    it 'sets `X-UA-Compatible` response header' do
      get :index
      expect(response.headers['X-UA-Compatible']).to eq('IE=edge')
    end

    it 'assigns to `@app_config`' do
      get :index
      expect(assigns(:app_config)).to eq AppConfig.instance
    end

    it 'sets the default pagination params' do
      get :index
      expect(controller.params.permit!.to_h).to include(page: 1, per_page: 50)
    end
  end
end
