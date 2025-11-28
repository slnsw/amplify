# frozen_string_literal: true

RSpec.describe VoiceBaseUploadJob, type: :job do
  describe '#perform' do
    let(:transcript) { create(:transcript) }

    before do
      allow(VoiceBase::VoicebaseApiService).to receive(:upload_media)
    end

    it 'calls VoicebaseApiService upload_media with transcript_id' do
      described_class.perform_now(transcript.id)
      expect(VoiceBase::VoicebaseApiService).to have_received(:upload_media).with(transcript.id)
    end
  end
end
