require "rails_helper"

RSpec.describe DailyAnalyticsJob, type: :job do
  describe "#perform" do
    it "deletes the cache and calls Institution.all_institution_disk_usage" do
      expect(Rails.cache).to receive(:delete).with("Institution:disk_usage:all")
      expect(Institution).to receive(:all_institution_disk_usage)
      described_class.new.perform
    end
  end
end
