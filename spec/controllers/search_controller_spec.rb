# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe '#index' do
    let!(:transcripts) { create_list(:transcript, 3) }

    before do
      allow(Theme).to receive(:order).with(name: :asc).and_return([])
      fake_search = instance_double(TranscriptSearch, transcripts: transcripts)
      allow(TranscriptSearch).to receive(:new).and_return(fake_search)
      get :index
    end

    context 'when requested format is html' do
      it 'responds with HTML content type' do
        expect(response.content_type).to include 'text/html'
      end

      it 'assigns @page_title as Search' do
        expect(assigns(:page_title)).to eq('Search')
      end

      it 'assigns @build_params with default page' do
        expect(assigns(:build_params)[:page]).to be >= 1
      end

      it 'assigns @transcripts from TranscriptSearch' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end

      it 'sets the form url to search_index_path' do
        expect(assigns(:form_url)).to eq(search_index_path)
      end

      it 'uses the application_v2 layout' do
        expect(response).to render_template(layout: 'application_v2')
      end
    end

    context 'when requested format is json' do
      it 'raises UnknownFormat' do
        expect { get :index, params: { format: :json } }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
