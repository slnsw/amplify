# frozen_string_literal: true

class CollectionDecorator < ApplicationDecorator
  delegate_all

  def transcript_items
    object.transcripts.size
  end

  def path
    "/#{institution.slug}/#{uid}"
  end

  def absolute_url
    Rails.application.routes.url_helpers.url_for(
      host: Rails.application.config.action_controller.default_url_options[:host],
      controller: 'collections',
      action: 'show',
      id: uid,
      only_path: false
    )
  end
end
