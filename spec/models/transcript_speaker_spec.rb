# frozen_string_literal: true

RSpec.describe TranscriptSpeaker, type: :model do
  it { is_expected.to belong_to(:speaker) }
  it { is_expected.to belong_to(:transcript) }
  it { is_expected.to be_versioned }

  describe '.getByTranscriptId' do
    let(:transcript) { create(:transcript) }
    let!(:speaker1) { create(:speaker) }
    let!(:speaker2) { create(:speaker) }

    before do
      described_class.create!(transcript: transcript, speaker: speaker1)
      described_class.create!(transcript: transcript, speaker: speaker2)
    end

    it 'returns speakers for the transcript' do
      result = described_class.getByTranscriptId(transcript.id)
      expect(result).to include(speaker1, speaker2)
    end

    it 'caches the result for 1 hour' do
      allow(Rails.cache).to receive(:fetch).and_call_original
      described_class.getByTranscriptId(transcript.id)
      expect(Rails.cache).to have_received(:fetch)
        .with("/transcript/#{transcript.id}/speakers", expires_in: 1.hour)
    end
  end
end
