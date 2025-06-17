# frozen_string_literal: true

require 'test_helper'

class TranscriptLinesControllerTest < ActionController::TestCase
  setup do
    @transcript_line = transcript_lines(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcript_lines)
  end

  test 'should create transcript_line' do
    assert_difference('TranscriptLine.count') do
      post :create, params: { transcript_line: { end_time: @transcript_line.end_time, notes: @transcript_line.notes, sequence: @transcript_line.sequence, speaker_id: @transcript_line.speaker_id, start_time: @transcript_line.start_time, text: @transcript_line.text, transcript_id: @transcript_line.transcript_id, transcript_status_id: @transcript_line.transcript_status_id } }
    end

    assert_response 201
  end

  test 'should show transcript_line' do
    get :show, params: { id: @transcript_line }
    assert_response :success
  end

  test 'should update transcript_line' do
    put :update, params: { id: @transcript_line, transcript_line: { end_time: @transcript_line.end_time, notes: @transcript_line.notes, sequence: @transcript_line.sequence, speaker_id: @transcript_line.speaker_id, start_time: @transcript_line.start_time, text: @transcript_line.text, transcript_id: @transcript_line.transcript_id, transcript_status_id: @transcript_line.transcript_status_id } }
    assert_response 204
  end

  test 'should destroy transcript_line' do
    assert_difference('TranscriptLine.count', -1) do
      delete :destroy, params: { id: @transcript_line }
    end

    assert_response 204
  end
end
