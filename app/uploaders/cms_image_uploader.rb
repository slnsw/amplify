# frozen_string_literal: true

class CmsImageUploader < CarrierWave::Uploader::Base
  include S3Identifier
end
