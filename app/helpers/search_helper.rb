module SearchHelper

  def item_tag(transcript, query)
    if !query.blank?
      tag = transcript.guess_text.empty? ? 'computer-generated text' : 'user-generated text'
      content_tag :div, "(#{tag})", class: 'search_item__line-type'
    end
  end


  def search_text(transcript, query)
    if !query.blank?
      full_path = "#{transcript.transcript.decorate.path}?t=#{time_display(transcript.start_time)}"
      text = transcript.guess_text.empty? ? transcript.original_text : transcript.guess_text
      if text.blank?
        transcript_line = transcript.transcript_lines.first
        text = transcript_line&.guess_text
        text = transcript_line&.original_text if text.blank? 
        text = text.to_s.truncate(100) 
      end
      content_tag :a, href: full_path, class: 'search_item__line' do
        "...#{text}.."
      end
    end
  end

  def start_time

  end
end
