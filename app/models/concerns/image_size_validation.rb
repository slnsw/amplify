# frozen_string_literal: true

module ImageSizeValidation
  extend ActiveSupport::Concern

  def image_size_restriction
    errors[:image] << 'Image should be less than 5MB' if image.size > 5.megabytes
  end
end
