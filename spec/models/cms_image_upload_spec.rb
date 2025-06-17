# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CmsImageUpload, type: :model do
  describe 'factory' do
    it 'is valid' do
      expect(build(:cms_image_upload)).to be_valid
    end
  end

  describe 'image uploader' do
    it 'mounts the CmsImageUploader on image' do
      expect(CmsImageUpload.uploaders[:image]).to eq(CmsImageUploader)
    end
  end
end
