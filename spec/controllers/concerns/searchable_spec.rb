# frozen_string_literal: true

RSpec.describe Searchable, type: :controller do
  controller(ApplicationController) do
    include Searchable

    def index
      @sort_params = sort_params
      @build_params = build_params
      @institution_id = select_institution_id
      load_institutions
      load_collection
      render plain: 'ok'
    end
  end

  describe '#sort_params' do
    context 'when params[:data] is present' do
      it 'permits sort parameters' do
        get :index, params: { data: { sort_id: '1', text: 'test', collection_id: %w[1 2] } }
        result = assigns(:sort_params)
        expect(result).to be_present
        expect(result['sort_id']).to eq('1')
        expect(result['text']).to eq('test')
      end

      it 'converts string collection_id to array' do
        get :index, params: { data: { collection_id: '5' } }
        expect(controller.send(:sort_params)[:collection_id]).to eq(['5'])
      end
    end

    context 'when params[:data] is blank' do
      it 'returns empty hash' do
        get :index
        expect(assigns(:sort_params)).to eq({})
      end
    end
  end

  describe '#build_params' do
    it 'rejects blank values' do
      get :index, params: { data: { text: 'test', sort_id: '', institution_id: '0' } }
      result = assigns(:build_params)
      expect(result).to be_present
      expect(result['text']).to eq('test')
    end

    it 'rejects arrays with blank first element' do
      get :index, params: { data: { theme: ['', 'value'] } }
      result = assigns(:build_params)
      expect(result).to eq({}) if result.present?
    end
  end

  describe '#select_institution_id' do
    let(:institution) { create(:institution) }
    let(:collection) { create(:collection, institution: institution) }

    context 'when institution_id is provided and > 0' do
      it 'returns the institution_id' do
        get :index, params: { data: { institution_id: institution.id.to_s } }
        expect(assigns(:institution_id)).to eq(institution.id)
      end
    end

    context 'when collection_id is provided' do
      it 'returns the collection institution_id' do
        get :index, params: { data: { collection_id: [collection.id.to_s] } }
        expect(assigns(:institution_id)).to eq(institution.id)
      end
    end
  end

  describe '#load_institutions' do
    let!(:institution1) { create(:institution, name: 'Institution A') }
    let!(:institution2) { create(:institution, name: 'Institution B') }

    it 'loads all institutions with "All Institutions" option' do
      get :index
      expect(assigns(:institutions).map(&:name)).to include('All Institutions', 'Institution A', 'Institution B')
    end

    it 'filters by collection_id when provided' do
      collection = create(:collection, institution: institution1)
      get :index, params: { data: { collection_id: [collection.id.to_s] } }
      expect(assigns(:institutions)).to be_present
    end
  end

  describe '#load_collection' do
    let(:institution) { create(:institution) }
    let!(:collection1) { create(:collection, :published, institution: institution) }
    let!(:collection2) { create(:collection, :published, institution: create(:institution)) }

    it 'loads all published collections when institution_id is 0' do
      get :index, params: { data: { institution_id: '0' } }
      expect(assigns(:collection)).to include(collection1, collection2)
    end

    it 'filters collections by institution_id' do
      get :index, params: { data: { institution_id: institution.id.to_s } }
      expect(assigns(:collection)).to include(collection1)
      expect(assigns(:collection)).not_to include(collection2)
    end
  end
end
