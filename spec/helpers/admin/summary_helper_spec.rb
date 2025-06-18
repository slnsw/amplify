require "rails_helper"

RSpec.describe Admin::SummaryHelper, type: :helper do
  describe ".duration_to_hms" do
    it "returns a humanized duration string from an integer" do
      expect(helper.duration_to_hms(2000)).to eq("00h 33m 20s")
      expect(helper.duration_to_hms(86401)).to eq("24h 00m 01s")
    end
  end
end
