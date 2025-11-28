# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImageSizeValidation, type: :model do
  # Test with an actual model that uses the concern
  describe '#image_size_restriction' do
    let(:institution) { build(:institution) }

    context 'when image size is under 5MB' do
      it 'does not add errors when image is small' do
        mock_image = double('image', size: 4.megabytes)
        allow(institution).to receive(:image).and_return(mock_image)
        institution.send(:image_size_restriction)
        expect(institution.errors[:image]).to be_empty
      end
    end

    context 'when image size is exactly 5MB' do
      it 'does not add errors at boundary' do
        mock_image = double('image', size: 5.megabytes)
        allow(institution).to receive(:image).and_return(mock_image)
        institution.send(:image_size_restriction)
        expect(institution.errors[:image]).to be_empty
      end
    end

    context 'when validating the concern exists' do
      it 'includes the concern in Institution model' do
        expect(Institution.ancestors).to include(ImageSizeValidation)
      end

      it 'includes the concern in Collection model' do
        expect(Collection.ancestors).to include(ImageSizeValidation)
      end

      it 'includes the concern in Transcript model' do
        expect(Transcript.ancestors).to include(ImageSizeValidation)
      end
    end
  end
end
