class PageDecorator < ApplicationDecorator
  delegate_all

  def display_content
    h.raw object.content
  end
end
