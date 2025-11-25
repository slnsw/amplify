# frozen_string_literal: true

RSpec.describe DailyAnalyticsJob, type: :job do
  describe '#perform' do
    before do
      allow(Rails.cache).to receive(:delete)
      allow(Institution).to receive(:all_institution_disk_usage)
    end

    it 'deletes the institution disk usage cache' do
      described_class.perform_now
      expect(Rails.cache).to have_received(:delete).with('Institution:disk_usage:all')
    end

    it 'recalculates institution disk usage' do
      described_class.perform_now
      expect(Institution).to have_received(:all_institution_disk_usage)
    end
  end
end
