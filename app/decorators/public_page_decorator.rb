# frozen_string_literal: true

class PublicPageDecorator < ApplicationDecorator
  delegate_all

  def display_content
    h.raw object.content
  end
end
