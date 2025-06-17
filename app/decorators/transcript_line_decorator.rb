# frozen_string_literal: true

class TranscriptLineDecorator < Draper::Decorator
  delegate_all

  def search_title
    "#{object.transcript.decorate.collection_title} - #{object.transcript.title}"
  end

  def image_url
    object.transcript.image_url
  end

  def humanize_duration(duration)
    "(#{h.display_time(duration)})" if duration.to_i.positive?
  end
end
