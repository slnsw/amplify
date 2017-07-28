class ImageUploader < CarrierWave::Uploader::Base
  include S3Identifier

  process :validate_dimensions

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Override the directory where uploaded files will be stored.
  # This path will be appended to the S3 bucket url.
  def store_dir
    "collections_v2/#{s3_collection_uid}/images/"
  end

  # Create different versions of your uploaded files:
  version :small do
    process resize_to_fit: [200, 200]
  end

  version :thumb, from_version: :small do
    process resize_to_fit: [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # Add a white list of mime types which are allowed to be uploaded.
  def content_type_whitelist
    /image\//
  end

  # check for images that are larger than you probably want
  # prevent pixel flood attack
  # Read more: https://github.com/carrierwaveuploader/carrierwave/wiki/Denial-of-service-vulnerability-with-maliciously-crafted-JPEGs--(pixel-flood-attack)
  def validate_dimensions
    manipulate! do |img|
      if img.dimensions.any?{|i| i > 8000 }
        raise CarrierWave::ProcessingError, "dimensions too large"
      end
      img
    end
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
end
