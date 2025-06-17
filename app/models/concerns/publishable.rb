# frozen_string_literal: true

module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published_at: nil) }
    scope :unpublished, -> { unscoped.where(published_at: nil) }

    after_save :publish_if_needed
  end

  def publish_if_needed
    return if saved_changes['publish'].blank?

    publish ? publish! : unpublish!
  end

  def published?
    !!published_at
  end

  def unpublished?
    !published?
  end

  def publish!
    update_column('published_at', Time.current)
  end

  def unpublish!
    update_column('published_at', nil)
  end
end
