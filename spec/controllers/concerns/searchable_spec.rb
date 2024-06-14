require 'rails_helper'

RSpec.describe Searchable do
  let(:controller) { FakesController.new }
  let(:params) { {} }

  before do
    class FakesController < ApplicationController
      include Searchable
    end

    allow(controller).to receive(:params).and_return(
      ActionController::Parameters.new(params)
    )
  end

  after do
    Object.send :remove_const, :FakesController
  end

  describe '#sort_params' do
    subject(:sort_params) { controller.send(:sort_params) }

    context 'turn collection id as array' do
      let(:params) do
        {
          data: {
            collection_id: '1'
          }
        }
      end

      it 'collection id as array' do
        expect(sort_params.dig('collection_id')).to eq (['1'])
      end
    end

    context 'require params' do
      let(:params) do
        {
          data: {
            sort_id: 'asc',
            text: 'any-text',
            q: 'any-query',
            institution_id: 'any institution id',
            theme: ['theme_1'],
            collection_id: ['1'],
            unrequired_params: 1
          }
        }
      end

      it 'returns required params' do
        expect(sort_params.keys).to contain_exactly(
          "sort_id", "text", "q", "institution_id", "theme", "collection_id"
        )
      end
    end
  end

  describe '#build_params' do
    subject(:build_params) { controller.send(:build_params) }

    let(:params) do
      {
        data: {
          sort_id: 'asc',
          text: 'any-text',
          q: 'any-query',
          institution_id: 'any institution id',
          theme: ['theme_1'],
          collection_id: ['1'],
          unrequired_params: 1
        }
      }
    end

    context 'when all params is present' do
      it 'returns all params' do
        expect(build_params.keys).to contain_exactly(
          "sort_id", "text", "q", "institution_id", "theme", "collection_id"
        )
      end
    end

    context 'when collection_id value is 0' do
      let(:params) do
        {
          data: {
            sort_id: 'asc',
            text: 'any-text',
            q: 'any-query',
            institution_id: 'any institution id',
            theme: ['theme_1'],
            collection_id: ['0'],
            unrequired_params: 1
          }
        }
      end

      it 'returns all params except collection id' do
        expect(build_params.keys).to contain_exactly(
          "sort_id", "text", "q", "institution_id", "theme"
        )
      end
    end
  end

  describe '#load_institutions' do
    subject(:load_institutions) { controller.send(:load_institutions) }

    context 'when collection id is present' do
      let(:collection) { create(:collection) }
      let(:params) do
        {
          data: {
            collection_id: [collection.id]
          }
        }
      end

      it 'it returns institution' do
        expect(load_institutions).to include(collection.institution)
      end
    end

    context 'when collection id is not present' do
      it 'returns all institution' do
        institution_a = create(:institution)
        institution_b = create(:institution)

        expect(load_institutions).to include(institution_a, institution_b)
      end
    end
  end

  describe '#load_collection' do
    subject(:load_collection) { controller.send(:load_collection) }

    let(:collection) { create(:collection) }

    context 'when institution params is present' do
      let(:params) do
        {
          data: {
            institution_id: collection.institution.id
          }
        }
      end

      it 'returns collection' do
        expect(load_collection).to contain_exactly(collection)
      end
    end

    context 'when institution params is not present' do
      it 'returns all collection' do
        collection_a = create(:collection)
        collection_b = create(:collection)

        expect(load_collection).to contain_exactly(collection_a, collection_b)
      end
    end
  end
end
