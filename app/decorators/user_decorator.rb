# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate_all

  def avatar_image
    object.image || 'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg'
  end
end
