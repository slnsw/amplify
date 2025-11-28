# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::StatsController, type: :controller do
  let(:institution) { create(:institution) }
  let(:stats_service) { instance_double(StatsService) }

  describe '#index' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(StatsService).to receive(:new).and_return(stats_service)
        allow(stats_service).to receive(:all_stats).and_return({ completed: 10 })
        allow(Flag).to receive(:pending_flags).and_return(Flag.none)
        get :index
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @stats' do
        expect(assigns(:stats)).to eq({ completed: 10 })
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
  end

  describe '#institution' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(StatsService).to receive(:new).and_return(stats_service)
        allow(stats_service).to receive(:transcript_edits).and_return([{ edit: 'data' }])
        allow(controller).to receive(:protect_against_forgery?).and_return(false)
        get :institution, params: { id: institution.id }, format: :js, xhr: true
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @stats' do
        expect(assigns(:stats)).to eq([{ edit: 'data' }])
      end
    end

    context 'when user is non-staff' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :institution, params: { id: 1 }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
