# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AnalyticsController, type: :controller do
  let(:institution) { create(:institution) }

  describe '#index' do
    context 'when user is staff with institution' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(ENV).to receive(:[]).with('LOOKER_STUDIO_IFRAME_URL').and_return('https://example.com/analytics')
        allow(ENV).to receive(:[]).with('DOMAIN').and_return('example.com')
        get :index
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @institution' do
        expect(assigns(:institution)).to eq(institution)
      end

      it 'assigns @analytics_url with institution guid' do
        expect(assigns(:analytics_url)).to include(institution.guid)
      end

      it 'includes the configured domain in the analytics url' do
        expect(assigns(:analytics_url)).to include('example.com')
      end
    end

    context 'when LOOKER_STUDIO_IFRAME_URL already has query params' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(ENV).to receive(:[]).with('LOOKER_STUDIO_IFRAME_URL').and_return('https://example.com/analytics?existing=1')
        allow(ENV).to receive(:[]).with('DOMAIN').and_return('example.com')
        get :index
      end

      it 'includes the institution guid in the analytics url' do
        expect(assigns(:analytics_url)).to include(institution.guid)
      end

      it 'includes the domain param in the analytics url' do
        expect(assigns(:analytics_url)).to include('domain=example.com')
      end

      it 'does not include the original query params' do
        expect(assigns(:analytics_url)).not_to include('existing=1')
      end
    end

    context 'when user is staff without institution' do
      let(:user) { create(:user, :moderator) }

      before do
        sign_in user
      end

      it 'raises routing error' do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context 'when user is non-staff' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :index
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is not signed in' do
      it 'redirects' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
