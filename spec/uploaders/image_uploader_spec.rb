# frozen_string_literal: true

require 'carrierwave/test/matchers'

RSpec.describe ImageUploader, type: :uploader do
  include CarrierWave::Test::Matchers

  let(:vendor) { Vendor.create!(uid: 'voice_base', name: 'VoiceBase') }
  let(:institution) { FactoryBot.create :institution }

  context 'collection image uploader' do
    let(:collection) do
      Collection.create!(
        description: "A summary of the collection's content",
        url: 'collection_catalogue_reference',
        uid: 'collection-uid',
        title: "The collection's title",
        vendor: vendor,
        institution_id: institution.id
      )
    end
    let(:uploader) { ImageUploader.new(collection, :image) }

    before do
      ImageUploader.enable_processing = true
      File.open(Rails.root.join('spec', 'fixtures', 'image.jpg')) { |f| uploader.store!(f) }
    end

    after do
      ImageUploader.enable_processing = false
      uploader.remove!
    end

    context 'the thumb version' do
      it 'scales down a landscape image to be exactly 64 by 64 pixels' do
        expect(uploader.thumb).to have_dimensions(100, 100)
      end
    end

    it 'has the correct format' do
      expect(uploader).to be_format('JPEG')
    end
  end

  context 'transcript image uploader' do
    let(:transcript) do
      create(:transcript,
             crop_x: '0',
             crop_y: '0',
             crop_w: '2000',
             crop_h: '900',
             image: File.open(Rails.root.join('spec', 'fixtures', '4k_example_image.jpg')))
    end
    let(:transcript_uploader) { ImageUploader.new(transcript, :image) }

    before do
      ImageUploader.enable_processing = true
      File.open(Rails.root.join('spec', 'fixtures', '4k_example_image.jpg')) { |f| transcript_uploader.store!(f) }
    end

    after do
      ImageUploader.enable_processing = false
      transcript_uploader.remove!
    end

    context 'the cropped thumb version' do
      it 'scales down a landscape image to be exactly 2000 by 900 pixels' do
        expect(transcript_uploader.cropped_thumb).to have_dimensions(2000, 900)
      end
    end
  end
end
