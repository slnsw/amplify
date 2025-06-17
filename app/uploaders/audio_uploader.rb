# frozen_string_literal: true

class AudioUploader < CarrierWave::Uploader::Base
  include S3Identifier

  # Override the directory where uploaded files will be stored.
  # This path will be appended to the S3 bucket url.
  def store_dir
    "collections_v2/#{s3_collection_uid}/audio/"
  end

  def cache_dir
    '/tmp/carrierwave/'
  end
end
