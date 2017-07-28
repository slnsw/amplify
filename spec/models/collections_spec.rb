require "rails_helper"

RSpec.describe Collection, type: :model do
  describe "associations" do
    it { is_expected.to have_many :transcripts }
    it { is_expected.to belong_to :vendor }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :vendor }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :uid }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :url }

    it { is_expected.to validate_uniqueness_of :uid }
    it { is_expected.to validate_uniqueness_of :title }
    it { is_expected.to validate_uniqueness_of :url }
  end

  let(:vendor) { Vendor.create(uid: 'voice_base', name: 'VoiceBase') }
  let!(:collection) do
    Collection.create!(
      description: "A summary of the collection's content",
      url: "collection_catalogue_reference",
      uid: "collection-uid",
      title: "The collection's title",
      vendor: vendor
    )
  end

  describe "#to_param" do
    it "returns the collection's uid" do
      expect(collection.to_param).to eq("collection-uid")
    end
  end

  describe "#published?" do
    it "confirms that the collection has a published_at date" do
      collection.update!(published_at: DateTime.current)
      expect(collection).to be_published
    end

    it "confirms that the collection has not been published" do
      collection.update!(published_at: nil)
      expect(collection).to_not be_published
    end
  end

  describe "validate uid does not change after create" do
    let(:vendor) { Vendor.create!(uid: 'voice_base', name: 'VoiceBase') }
    let(:collection) do
      Collection.new(
        uid: "collection_test",
        title: "test collection",
        url: "https://catalogue_collection",
        description: "test collection",
        vendor_id: vendor.id
      )
    end

    context "the collection has not yet been saved" do
      it "is valid" do
        expect(collection).to be_valid
      end
    end

    context "the collection is already persisted" do
      before do
        collection.save!
      end

      it "is invalid" do
        collection.uid = "new_value"
        expect(collection).to_not be_valid
        expect(collection.errors[:uid].first).to eq("cannot be updated")
      end
    end
  end
end
