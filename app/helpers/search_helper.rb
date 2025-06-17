# frozen_string_literal: true

module SearchHelper
  def item_tag(transcript, query)
    if query.present?
      tag = transcript.guess_text.empty? ? 'computer-generated text' : 'user-generated text'
      tag.div("(#{tag})", class: 'search_item__line-type')
    end
  end

  def search_text(transcript, query)
    if query.present?
      full_path = "#{transcript.transcript.decorate.path}?t=#{time_display(transcript.start_time)}"
      text = transcript.guess_text.empty? ? transcript.original_text : transcript.guess_text
      tag.a(href: full_path, class: 'search_item__line') do
        "...#{text}.."
      end
    end
  end

  def start_time; end
end
