# frozen_string_literal: true

RSpec.describe RecalculateTranscriptsJob, type: :job do
  describe '#perform' do
    let!(:transcript1) { create(:transcript, lines: 10, updated_at: 1.day.ago) }
    let!(:transcript2) { create(:transcript, lines: 10, updated_at: 2.days.ago) }
    let!(:transcript3) { create(:transcript, lines: 10, updated_at: 3.days.ago) }

    it 'queries transcripts ordered by updated_at desc' do
      allow_any_instance_of(Transcript).to receive(:recalculate)
      expect(Transcript).to receive(:order).with(updated_at: :desc).and_call_original
      described_class.perform_now
    end

    it 'limits to 250 transcripts' do
      allow_any_instance_of(Transcript).to receive(:recalculate)
      expect_any_instance_of(ActiveRecord::Relation).to receive(:limit).with(250).and_call_original
      described_class.perform_now
    end

    it 'calls recalculate on transcripts' do
      count = 0
      allow_any_instance_of(Transcript).to receive(:recalculate) { count += 1 }
      described_class.perform_now
      expect(count).to be >= 3
    end
  end
end
