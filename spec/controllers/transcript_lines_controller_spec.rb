require "rails_helper"

RSpec.describe TranscriptLinesController, type: :controller do
  let(:staff_user) { create(:user, :moderator) }
  let(:transcript_line) { create(:transcript_line) }

  before do
    allow(controller).to receive(:logged_in_user).and_return(staff_user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe "POST #resolve" do
    context "when user is staff and transcript_line exists" do
      it "calls resolve on transcript_line and Flag and returns no_content" do
        allow(TranscriptLine).to receive(:find).with(transcript_line.id.to_s).and_return(transcript_line)
        expect(transcript_line).to receive(:resolve)
        expect(Flag).to receive(:resolve).with(transcript_line.id)
        post :resolve, params: { id: transcript_line.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when user is not staff" do
      it "does not call resolve and returns no_content" do
        non_staff = create(:user)
        allow(controller).to receive(:logged_in_user).and_return(non_staff)
        allow(TranscriptLine).to receive(:find).with(transcript_line.id.to_s).and_return(transcript_line)
        expect(transcript_line).not_to receive(:resolve)
        expect(Flag).not_to receive(:resolve)
        post :resolve, params: { id: transcript_line.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when transcript_line does not exist" do
      it "returns no_content" do
        allow(TranscriptLine).to receive(:find).with("999").and_return(nil)
        post :resolve, params: { id: 999 }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
