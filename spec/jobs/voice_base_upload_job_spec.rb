# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoiceBaseUploadJob, type: :job do
  let(:transcript_id) { 123 }

  it 'calls VoiceBase::VoicebaseApiService.upload_media with the transcript_id' do
    expect(VoiceBase::VoicebaseApiService).to receive(:upload_media).with(transcript_id)
    described_class.perform_now(transcript_id)
  end
end
