# frozen_string_literal: true

require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  setup do
    @flag = flags(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:flags)
  end

  test 'should create flag' do
    assert_difference('Flag.count') do
      post :create, params: { flag: { flag_type_id: @flag.flag_type_id, is_deleted: @flag.is_deleted, session_id: @flag.session_id, text: @flag.text, transcript_id: @flag.transcript_id, transcript_line_id: @flag.transcript_line_id, user_id: @flag.user_id } }
    end

    assert_response 201
  end

  test 'should show flag' do
    get :show, params: { id: @flag }
    assert_response :success
  end

  test 'should update flag' do
    put :update, params: { id: @flag, flag: { flag_type_id: @flag.flag_type_id, is_deleted: @flag.is_deleted, session_id: @flag.session_id, text: @flag.text, transcript_id: @flag.transcript_id, transcript_line_id: @flag.transcript_line_id, user_id: @flag.user_id } }
    assert_response 204
  end

  test 'should destroy flag' do
    assert_difference('Flag.count', -1) do
      delete :destroy, params: { id: @flag }
    end

    assert_response 204
  end
end
