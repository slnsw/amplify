# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsController, type: :controller do
  describe '#index' do
    let(:institution) { create(:institution, slug: 'inst-slug') }
    let(:transcripts) { [build_stubbed(:transcript)] }

    before do
      allow(controller).to receive(:build_params).and_return({})
      allow(TranscriptService).to receive(:search).and_return(transcripts)
      allow(Theme).to receive(:order).and_return([])
      allow(SortList).to receive(:list).and_return([])
      allow(Institution).to receive_message_chain(:friendly, :find).and_return(institution) # rubocop:disable RSpec/MessageChain
      controller.instance_variable_set(:@global_content, {})
    end

    context 'when requested format is html' do
      before { get :index, params: { path: institution.slug } }

      it 'responds with HTML content type' do
        expect(response.content_type).to include 'text/html'
      end

      it 'assigns `@transcripts` from TranscriptService' do
        expect(assigns(:transcripts)).to eq(transcripts)
      end

      it 'sets `@disabled` to true' do
        expect(assigns(:disabled)).to be_truthy
      end

      it 'sets the form url' do
        expect(assigns(:form_url)).to eq(institution_path(path: institution.slug))
      end

      it 'includes the institution slug in build_params' do
        expect(assigns(:build_params)[:institution]).to eq(institution.slug)
      end
    end

    context 'when params_list includes a collection_id' do
      let(:collection) { create(:collection, uid: 'col-uid', title: 'My Collection', institution: institution) }

      before do
        allow(Collection).to receive_message_chain(:published, :order).and_return(Collection.where(id: collection.id))
        get :index, params: { path: "#{institution.slug}/#{collection.uid}" }
      end

      it 'assigns `@collection` with the specified collection' do
        expect(assigns(:collection).first.title).to eq('My Collection')
      end

      it 'adds collection title to build_params' do
        expect(assigns(:build_params)[:collections]).to eq([collection.title])
      end
    end

    context 'when params_list does not include a collection_id' do
      before do
        allow(Collection).to receive_message_chain(:published, :order).and_return(Collection.none) # rubocop:disable RSpec/MessageChain
        get :index, params: { path: institution.slug }
      end

      it 'assigns @collection as a relation (possibly empty)' do
        expect(assigns(:collection)).to be_a(ActiveRecord::Relation)
      end
    end

    context 'when requested format is not html' do
      it 'returns not found' do
        get :index, params: { path: institution.slug, format: :json }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
