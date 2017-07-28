require "carrierwave/test/matchers"

RSpec.describe ImageUploader, type: :uploader do
  include CarrierWave::Test::Matchers
  
  let(:vendor) { Vendor.create!(uid: 'voice_base', name: 'VoiceBase') }
  let(:collection) do
    Collection.create!(
      description: "A summary of the collection's content",
      url: "collection_catalogue_reference",
      uid: "collection-uid",
      title: "The collection's title",
      vendor: vendor
    )
  end
  let(:uploader) { ImageUploader.new(collection, :image) }

  before do
    ImageUploader.enable_processing = true
    File.open(Rails.root.join("spec", "fixtures", "image.jpg")) { |f| uploader.store!(f) }
  end

  after do
    ImageUploader.enable_processing = false
    uploader.remove!
  end

  context "the thumb version" do
    it "scales down a landscape image to be exactly 64 by 64 pixels" do
      expect(uploader.thumb).to have_dimensions(100, 100)
    end
  end

  it "has the correct format" do
    expect(uploader).to be_format("JPEG")
  end
end
