# frozen_string_literal: true

require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  setup do
    @collection = collections(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:collections)
  end

  test 'should create collection' do
    assert_difference('Collection.count') do
      post :create, params: { collection: { description: @collection.description, image_url: @collection.image_url, title: @collection.title, uid: @collection.uid, url: @collection.url, vendor_id: @collection.vendor_id, vendor_identifier: @collection.vendor_identifier } }
    end

    assert_response 201
  end

  test 'should show collection' do
    get :show, params: { id: @collection }
    assert_response :success
  end

  test 'should update collection' do
    put :update, params: { id: @collection, collection: { description: @collection.description, image_url: @collection.image_url, title: @collection.title, uid: @collection.uid, url: @collection.url, vendor_id: @collection.vendor_id, vendor_identifier: @collection.vendor_identifier } }
    assert_response 204
  end

  test 'should destroy collection' do
    assert_difference('Collection.count', -1) do
      delete :destroy, params: { id: @collection }
    end

    assert_response 204
  end
end
