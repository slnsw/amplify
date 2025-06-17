# frozen_string_literal: true

class PageController < ApplicationController
  layout 'application_v2'

  def show
    load_page(params[:id])
  end

  def faq
    @page_title = 'Frequently Asked Questions'
    load_page('faq')
  end

  def about
    load_page('about')
  end

  def tutotial
    load_page('tutorial')
  end

  def preview
    load_page(params[:id])
  end

  private

  def load_page(key)
    page = Page.where('lower(page_type) = ?', key.downcase).first
    @public_page = page&.public_page&.decorate

    @page_title ||= key.humanize
    if page.admin_access && !current_user&.staff?
      # pages that can only be accessed by staff
      render template: 'page/no_access'
    else
      # public access pages
      render template: 'page/show'
    end
  end
end
