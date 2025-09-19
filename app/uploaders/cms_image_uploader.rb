class CmsImageUploader < CarrierWave::Uploader::Base
  include S3Identifier
end
