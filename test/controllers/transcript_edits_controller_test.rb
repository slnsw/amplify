# frozen_string_literal: true

require 'test_helper'

class TranscriptEditsControllerTest < ActionController::TestCase
  setup do
    @transcript_edit = transcript_edits(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcript_edits)
  end

  test 'should create transcript_edit' do
    assert_difference('TranscriptEdit.count') do
      post :create, params: { transcript_edit: { session_id: @transcript_edit.session_id, text: @transcript_edit.text, transcript_id: @transcript_edit.transcript_id, transcript_line_id: @transcript_edit.transcript_line_id, user_id: @transcript_edit.user_id, weight: @transcript_edit.weight } }
    end

    assert_response 201
  end

  test 'should show transcript_edit' do
    get :show, params: { id: @transcript_edit }
    assert_response :success
  end

  test 'should update transcript_edit' do
    put :update, params: { id: @transcript_edit, transcript_edit: { session_id: @transcript_edit.session_id, text: @transcript_edit.text, transcript_id: @transcript_edit.transcript_id, transcript_line_id: @transcript_edit.transcript_line_id, user_id: @transcript_edit.user_id, weight: @transcript_edit.weight } }
    assert_response 204
  end

  test 'should destroy transcript_edit' do
    assert_difference('TranscriptEdit.count', -1) do
      delete :destroy, params: { id: @transcript_edit }
    end

    assert_response 204
  end
end
