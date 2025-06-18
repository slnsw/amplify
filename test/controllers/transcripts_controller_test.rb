require "test_helper"

class TranscriptsControllerTest < ActionController::TestCase
  setup do
    @transcript = transcripts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcripts)
  end

  test "should create transcript" do
    assert_difference("Transcript.count") do
      post :create, transcript: { audio_url: @transcript.audio_url, batch_id: @transcript.batch_id, collection_id: @transcript.collection_id, created_by: @transcript.created_by, description: @transcript.description, duration: @transcript.duration, image_url: @transcript.image_url, lines: @transcript.lines, notes: @transcript.notes, order: @transcript.order, title: @transcript.title, transcript_processed_at: @transcript.transcript_processed_at, transcript_retrieved_at: @transcript.transcript_retrieved_at, transcript_status_id: @transcript.transcript_status_id, uid: @transcript.uid, url: @transcript.url, vendor_id: @transcript.vendor_id, vendor_identifier: @transcript.vendor_identifier }
    end

    assert_response 201
  end

  test "should show transcript" do
    get :show, id: @transcript
    assert_response :success
  end

  test "should update transcript" do
    put :update, id: @transcript, transcript: { audio_url: @transcript.audio_url, batch_id: @transcript.batch_id, collection_id: @transcript.collection_id, created_by: @transcript.created_by, description: @transcript.description, duration: @transcript.duration, image_url: @transcript.image_url, lines: @transcript.lines, notes: @transcript.notes, order: @transcript.order, title: @transcript.title, transcript_processed_at: @transcript.transcript_processed_at, transcript_retrieved_at: @transcript.transcript_retrieved_at, transcript_status_id: @transcript.transcript_status_id, uid: @transcript.uid, url: @transcript.url, vendor_id: @transcript.vendor_id, vendor_identifier: @transcript.vendor_identifier }
    assert_response 204
  end

  test "should destroy transcript" do
    assert_difference("Transcript.count", -1) do
      delete :destroy, id: @transcript
    end

    assert_response 204
  end
end
