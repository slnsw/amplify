require 'rails_helper'

RSpec.describe VoiceBaseUploadJob do
  let!(:transcript) { create(:transcript) }
  let(:user) { create(:user) }

  describe "#perform_later" do
    it "enqueues job" do
      ActiveJob::Base.queue_adapter = :test

      expect { described_class.perform_later(transcript) }.to have_enqueued_job
    end

    it 'execute VoiceBase API' do
      allow(VoiceBase::VoicebaseApiService).to receive(:upload_media).with(transcript.id)

      expect(VoiceBase::VoicebaseApiService).to receive(:upload_media).with(transcript.id)
      described_class.perform_now(transcript.id)
    end
  end
end
