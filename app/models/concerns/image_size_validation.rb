module ImageSizeValidation
  extend ActiveSupport::Concern

  def image_size_restriction
    if image.size > 5.megabytes
      errors[:image] << "Image should be less than 5MB"
    end
  end
end
