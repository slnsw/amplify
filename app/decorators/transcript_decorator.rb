class TranscriptDecorator < Draper::Decorator
  delegate_all

  def path
    "/transcripts/#{institution.slug}/#{collection.uid}/#{object.uid}"
  end

  def absolute_url
    return unless institution&.slug && collection&.uid && object&.uid

    url_options = Rails.application.config.action_controller.default_url_options || {}
    h.transcript_url(
      institution: institution.slug,
      collection: collection.uid,
      id: object.uid,
      **url_options
    )
  end

  def collection
    object.collection
  end

  def institution
    collection&.institution
  end

  def collection_title
    collection&.title
  end

  def homepage_description
    text = Sanitize.fragment(object.description, parser_options: { max_tree_depth: -1 })
    h.truncate(text, length: 50, separator: ' ', escape: false)
  end

  def search_title
    "#{collection_title} - #{object.title}"
  end

  def humanize_duration(duration = object.duration)
    h.display_time(duration)
  end

  def humanize_contributors
    h.pluralize(object.users_contributed, 'contributor')
  end

  def display_percentage_edits
    (object.percent_edited - object.percent_reviewing - object.percent_completed)
  end

  def display_edited_percentage
    h.content_tag(:div, '', class: "item-status-bar edited", style: "width: #{object.percent_edited}%")
  end

  def display_completed_percentage
    h.content_tag(:div, '', class: "item-status-bar completed", style: "width: #{object.percent_completed}%")
  end

  def display_reviewing_percentage
    h.content_tag(:div, '', class: "item-status-bar reviewing", style: "width: #{object.percent_reviewing}%; left: #{object.percent_completed}%;")
  end

  def display_status_consensus
    display_status("#{object.percent_completed}% reached consensus", 'completed', object.percent_completed)
  end

  def display_status_reviewing
    display_status("#{object.percent_reviewing}% awaiting review", 'reviewing', object.percent_reviewing)
  end

  def display_status_edited
    display_status("#{object.percent_edited}% have edits", 'edited', object.percent_edited)
  end

  def has_started?
    object.percent_edited.to_i + object.percent_reviewing.to_i + object.percent_completed.to_i > 0
  end

  def display_status(text, klass, percentage)
    if klass != 'completed' && object.percent_completed < 100
      h.content_tag(:div, text, class: "transcript_item__status-text") if percentage > 0
    end
  end

  def check_status(column)
    object.transcript_type.to_s == column
  end
end
