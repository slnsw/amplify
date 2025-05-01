class ImageUploader < CarrierWave::Uploader::Base
  include S3Identifier

  process :validate_dimensions

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  # Override the directory where uploaded files will be stored.
  # This path will be appended to the S3 bucket url.
  def store_dir
    if model.is_a?(Institution)
      "institutions/#{model.id}/images/"
    elsif model.is_a?(AppConfig)
      "app_configs/#{model.id}/images/"
    else
      "collections_v2/#{s3_collection_uid}/images/"
    end
  end

  # Create different versions of your uploaded files:
  version :small do
    process resize_to_fit: [200, 200]
  end

  version :medium do
    process resize_to_fit: [800, 800]
  end

  version :logo do
    process resize_to_fit: [232, 193]
  end

  version :hero_image do
    process resize_to_fit: [1261, 516]
  end

  version :hero_thumb, from_version: :hero_image do
    process resize_to_fit: [100, 100]
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

  version :cropped_thumb do
    process :crop
  end

  def crop
    if model.class.to_s == 'Transcript' && model.crop_x.present?
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop([[w, h].join('x'),[x, y].join('+')].join('+'))
      end
    end
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
