# frozen_string_literal: true

require 'rails_helper'

class DummyController < ApplicationController
  include Searchable

  def params=(val)
    @_params = ActionController::Parameters.new(val)
  end

  def params
    @_params || ActionController::Parameters.new
  end
end

RSpec.describe Searchable, type: :controller do
  let(:controller) { DummyController.new }

  describe '#sort_params' do
    it 'returns permitted params with array conversion' do
      controller.params = { data: { collection_id: '1', theme: ['foo'], sort_id: '2', text: 'abc', q: 'q', institution_id: '3' } }
      expect(controller.send(:sort_params)).to eq({
                                                    'collection_id' => ['1'],
                                                    'theme' => ['foo'],
                                                    'sort_id' => '2',
                                                    'text' => 'abc',
                                                    'q' => 'q',
                                                    'institution_id' => '3'
                                                  })
    end

    it 'returns empty hash if params[:data] is blank' do
      controller.params = {}
      expect(controller.send(:sort_params)).to eq({})
    end
  end

  describe '#build_params' do
    it 'removes blank and zero values' do
      controller.params = { data: { collection_id: ['0', ''], theme: [''], sort_id: '0', text: '', q: nil, institution_id: '0' } }
      expect(controller.send(:build_params)).to eq({})
    end

    it 'keeps valid values' do
      controller.params = { data: { collection_id: ['1'], theme: ['foo'], sort_id: '2', text: 'abc', q: 'q', institution_id: '3' } }
      expect(controller.send(:build_params)).to eq({
                                                     'collection_id' => ['1'],
                                                     'theme' => ['foo'],
                                                     'sort_id' => '2',
                                                     'text' => 'abc',
                                                     'q' => 'q',
                                                     'institution_id' => '3'
                                                   })
    end
  end

  describe '#select_institution_id' do
    let!(:institution) { create(:institution) }
    let!(:collection) { create(:collection, institution: institution) }

    it 'returns institution_id if present and > 0' do
      controller.params = { data: { institution_id: institution.id.to_s } }
      expect(controller.send(:select_institution_id)).to eq(institution.id)
    end

    it "returns collection's institution_id if institution_id is 0 and collection_id is present" do
      controller.params = { data: { institution_id: '0', collection_id: [collection.id.to_s] } }
      expect(controller.send(:select_institution_id)).to eq(institution.id)
    end

    it 'returns 0 if neither institution_id nor collection_id is present' do
      controller.params = { data: { institution_id: '0', collection_id: ['0'] } }
      expect(controller.send(:select_institution_id)).to eq(0)
    end
  end
end
