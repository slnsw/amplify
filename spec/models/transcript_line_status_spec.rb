# frozen_string_literal: true

RSpec.describe TranscriptLineStatus, type: :model do
  it { is_expected.to be_versioned }

  describe '.allCached' do
    let!(:status1) { described_class.create!(name: 'Status 1') }
    let!(:status2) { described_class.create!(name: 'Status 2') }

    it 'returns all transcript line statuses' do
      result = described_class.allCached
      expect(result).to include(status1, status2)
    end

    it 'caches the result for 1 day' do
      allow(Rails.cache).to receive(:fetch).and_call_original
      described_class.allCached
      expect(Rails.cache).to have_received(:fetch)
        .with('transcript_line_statuses', expires_in: 1.day)
    end
  end
end
