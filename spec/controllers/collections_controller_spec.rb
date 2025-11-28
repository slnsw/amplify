# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  describe '#index' do
    let!(:alpha) { create(:institution, name: 'Alpha Institution', hidden: false) }
    let!(:beta) { create(:institution, name: 'Beta Institution', hidden: false) }
    let!(:hidden) { create(:institution, name: 'Hidden Institution', hidden: true) }

    context 'when requested format is html' do
      before do
        get :index
      end

      it 'responds with HTML content type' do
        expect(response.content_type).to include 'text/html'
      end
    end

    context 'when requested format is json' do
      before do
        get :index, as: :json
      end

      it 'responds with json content type' do
        expect(response.content_type).to include 'application/json'
      end
    end

    context 'when institutions exist' do
      before do
        get :index
      end

      it 'assigns @institutions to only include published institutions' do
        expect(assigns(:institutions)).to contain_exactly(alpha, beta)
      end

      it 'does not include hidden institutions' do
        expect(assigns(:institutions)).not_to include(hidden)
      end

      it 'assigns @institutions sorted by name' do
        expect(assigns(:institutions)).to eq([alpha, beta])
      end

      it 'sets the page title' do
        expect(assigns(:page_title)).to eq('Collections')
      end

      it 'uses the application_v2 layout for index' do
        expect(controller.class._layout).to eq 'application_v2'
      end
    end

    context 'when a page exists for collections' do
      let(:public_page) { build_stubbed(:public_page) }
      let(:page) { build_stubbed(:page, public_page: public_page) }

      before do
        allow(Page).to receive(:find_by).with(page_type: 'collections').and_return(page)
        allow(public_page).to receive(:decorate).and_call_original
        get :index
      end

      it 'assigns `@page` with the decorated public page' do
        expect(assigns(:page)).to be_instance_of(PublicPageDecorator)
      end
    end

    context 'when no page exists for collections' do
      before do
        allow(Page).to receive(:find_by).with(page_type: 'collections').and_return(nil)
        get :index
      end

      it 'assigns `@page` with blank' do
        expect(assigns(:page)).to be_blank
      end
    end

    context 'when params are provided' do
      before do
        get :index, params: { foo: 'bar' }
      end

      it 'assigns @build_params to the params hash' do
        expect(assigns(:build_params).permit!.to_h).to include('foo' => 'bar')
      end
    end
  end

  describe '#list' do
    let(:collection) { build_stubbed(:collection) }

    context 'when requested format is js' do
      before do
        allow(CollectionsService).to receive(:by_institution).with('inst-slug').and_return([collection])
        post :list, params: { institution_slug: 'inst-slug' }, as: :js
      end

      it 'assigns @collections from CollectionsService' do
        expect(assigns(:collections)).to eq([collection])
      end
    end

    context 'when requested format is html' do
      it 'raises UnknownFormat' do
        allow(CollectionsService).to receive(:by_institution).with('inst-slug').and_return([collection])
        expect { post :list, params: { institution_slug: 'inst-slug' } }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end

  describe '#show' do
    let!(:collection) { create(:collection) }

    context 'when requested format is html' do
      it 'raises UnknownFormat' do
        expect { get :show, params: { id: collection.uid } }.to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'when requested format is json' do
      before do
        get :show, params: { id: collection.uid }, as: :json
      end

      it 'assigns @collection correctly' do
        expect(assigns(:collection)).to eq(collection)
      end

      it 'responds with json content type' do
        expect(response.content_type).to include 'application/json'
      end

      it 'responds with success status' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when collection does not exist' do
      it 'sets collection to nil' do
        get :show, params: { id: 'nonexistent' }, as: :json
        expect(assigns(:collection)).to be_nil
        expect(response).to have_http_status(:success)
      end
    end
  end
end
