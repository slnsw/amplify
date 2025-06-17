# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AnalyticsController, type: :controller do
  let(:institution) { create(:institution, guid: 'abc123') }
  let(:user) { create(:user, :admin, institution: institution) }

  before do
    allow(controller).to receive(:authenticate_staff!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    stub_const('ENV', ENV.to_hash.merge('LOOKER_STUDIO_IFRAME_URL' => 'https://looker.example.com', 'DOMAIN' => 'example.org'))
  end

  describe 'GET #index' do
    context 'when user has an institution' do
      it 'assigns @institution and @analytics_url' do
        get :index
        expect(assigns(:institution)).to eq(institution)
        expect(assigns(:analytics_url)).to include('https://looker.example.com')
        expect(assigns(:analytics_url)).to include('guid=abc123')
        expect(assigns(:analytics_url)).to include('domain=example.org')
        expect(response).to render_template(:index)
      end
    end

    context 'when user has no institution' do
      before { allow(user).to receive(:institution).and_return(nil) }

      it 'raises ActionController::RoutingError' do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
