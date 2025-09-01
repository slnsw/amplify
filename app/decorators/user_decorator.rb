class UserDecorator < ApplicationDecorator
  delegate_all

  def avatar_image
    if object.image
      object.image
    else
      'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg'
    end
  end
end
