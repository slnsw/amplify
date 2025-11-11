# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SummaryController, type: :controller do
  let(:institution) { create(:institution) }
  let(:stats_service) { instance_double(StatsService) }

  describe '#index' do
    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(StatsService).to receive(:new).and_return(stats_service)
        allow(stats_service).to receive_messages(
          completion_stats: { total: { count: 100 }, duration: { hours: 10 }, completed: 50 },
          disk_usage: { size: 1024 }
        )
        get :index
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
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

  describe '#details' do
    let(:collection) { create(:collection, institution: institution) }

    context 'when user is staff' do
      let(:user) { create(:user, :moderator, institution: institution) }

      before do
        sign_in user
        allow(StatsService).to receive(:new).and_return(stats_service)
        allow(stats_service).to receive_messages(
          completion_stats: { total: { count: 100 }, duration: { hours: 10 }, completed: 50 },
          disk_usage: { size: 1024 }
        )
        get :details, params: { institution_id: institution.id, collection_id: collection.id }, format: :js, xhr: true
      end

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @selected_collection_id' do
        expect(assigns(:selected_collection_id)).to eq(collection.id)
      end
    end

    context 'when user is non-staff' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :details, params: { institution_id: 1 }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
