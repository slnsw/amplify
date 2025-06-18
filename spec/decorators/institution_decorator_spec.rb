require "rails_helper"

RSpec.describe InstitutionDecorator do
  let(:institution) { create(:institution, slug: "test-slug", url: "http://example.com") }
  let(:decorator) { described_class.new(institution) }

  describe "#path" do
    it "returns the institution path with slug" do
      expect(decorator.path).to eq("/test-slug")
    end
  end

  describe "#absolute_url" do
    it "returns the institution url" do
      expect(decorator.absolute_url).to eq("http://example.com")
    end
  end
end
