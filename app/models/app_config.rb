# frozen_string_literal: true

class AppConfig < ApplicationRecord
  include ActiveRecord::Singleton

  mount_uploader :image, ImageUploader
end
