module SearchHelper

  def item_tag(transcript, query)
    if !query.blank?
      tag = transcript.guess_text.empty? ? 'computer-generated text' : 'user-generated text'
      content_tag :div, "(#{tag})", class: 'item-line-type'
    end
  end

  def search_text(transcript, query)
    if query.blank?
      full_path = "#{transcript.path}?t=#{(transcript.duration / 1000)}"
      text = transcript.guess_text.empty? ? transcript.original_text : transcript.guess_text
      content_tag :a, href: full_path, class: 'item-line' do
        "...#{text}.."
      end
    end
  end
end
