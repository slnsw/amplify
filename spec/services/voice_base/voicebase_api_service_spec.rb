# ruby

require "rails_helper"

RSpec.describe VoiceBase::VoicebaseApiService do
  describe ".upload_media" do
    let(:transcript) { create(:transcript, audio_url: "http://audio.url/file.mp3") }
    let(:client_double) { instance_double(Voicebase::Client) }

    before do
      allow(Voicebase::Client).to receive(:new).and_return(client_double)
      allow(Bugsnag).to receive(:notify)
    end

    context "when upload returns errors" do
      let(:error_response) { double("Response", body: { errors: "Some error" }.to_json) }

      it "notifies Bugsnag and does not update voicebase_media_id" do
        allow(client_double).to receive(:upload_media).and_return(error_response)

        described_class.upload_media(transcript.id)

        expect(Bugsnag).to have_received(:notify).with(/Could not do Voicebase audio upload/)
        expect(transcript.reload.voicebase_media_id).to be_nil
      end
    end

    context "when upload is successful" do
      let(:media_id) { "12345abc" }
      let(:success_response) { double("Response", body: { mediaId: media_id }.to_json) }

      it "updates the transcript with the media id" do
        allow(client_double).to receive(:upload_media).and_return(success_response)

        described_class.upload_media(transcript.id)

        expect(transcript.reload.voicebase_media_id).to eq(media_id)
        expect(Bugsnag).not_to have_received(:notify)
      end
    end
  end
end
