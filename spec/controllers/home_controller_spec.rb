# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe '#index' do
    subject { get :index }

    let(:params) { { q: 'test' } }
    let(:transcripts) { [build_stubbed(:transcript)] }
    let(:user) { build_stubbed(:user) }

    before do
      allow(controller).to receive(:build_params).and_return(params)
      allow(TranscriptService).to receive(:search).with(params).and_return(transcripts)
      allow(Theme).to receive(:order).with(name: :asc).and_return([])
      allow(SortList).to receive(:list).and_return([])
    end

    context 'when current_user is present' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :index
      end

      it 'responds with HTML content type' do
        expect(response.content_type).to include 'text/html'
      end

      it 'assigns `@build_params` with correct params' do
        expect(assigns(:build_params)).to eq(params)
      end

      it 'assigns `@transcripts` from the TranscriptService' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end

      it 'sets layout to `application_v2`' do
        expect(response).to render_template(layout: 'application_v2')
      end
    end

    context 'when current_user is nil' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :index
      end

      it 'responds with HTML content type' do
        expect(response.content_type).to include 'text/html'
      end

      it 'assigns `@build_params` with correct params' do
        expect(assigns(:build_params)).to eq(params)
      end

      it 'assigns `@transcripts` from the TranscriptService' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end

      it 'sets layout to `application_v2`' do
        expect(controller.class._layout).to eq 'application_v2'
      end
    end
  end

  describe '#index with rendered views (hero content url=nil guard)' do
    render_views

    before do
      allow(controller).to receive(:build_params).and_return({})
      allow(TranscriptService).to receive(:search).and_return([])
      allow(Theme).to receive(:order).with(name: :asc).and_return([])
      allow(SortList).to receive(:list).and_return([])
    end

    it 'renders without NameError when institution is nil (url not defined)' do
      # home/index renders _hero_content with institution: nil — url must be initialized
      expect { get :index }.not_to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
