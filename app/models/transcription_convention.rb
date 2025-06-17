# frozen_string_literal: true

class TranscriptionConvention < ApplicationRecord
  has_paper_trail
  belongs_to :institution

  def self.create_default(institution_id)
    default_list.each do |convention|
      TranscriptionConvention.create(
        institution_id: institution_id,
        convention_key: convention[0],
        convention_text: convention[1],
        example: convention[2]
      )
    end
  end

  def self.default_list
    # rubocop:disable Metrics/LineLength
    [
      ['Language', 'English (Australian)', '“Colour” not “Color”, “Organise” not “Organize”'],
      ['Contractions', 'Transcribe as you hear them', '“Shoulda”, “Didn’t”'],
      ['Numbers', 'Transcribe as numerals', '“11 West 40th Street”'],
      ['Filled Pauses & Hesitations', 'Transcribe as you hear them', '“ah”, “eh”, “um”'],
      ['Noise', 'Transcribe in brackets; use descriptive language', '“And then we [door slam]”, “So cold! [Brrrrr]”'],
      ['Partial words', 'If someone stops speaking in the middle of a word, transcribe as much of the word as they say; follow it with a dash', '“Tes- Testing”, “Absolu- Absolutely”'],
      ['Hard-to-understand', 'For speech that is difficult or impossible to understand, use question marks before and after', '“And she told me that ?I should just leave?”, “Her name was ?inaudible?”'],
      ['Truncated Words', 'Sometimes words may seem to be repeated from the end of one line to the start of the next. Transcribe these as you hear them and use your best judgment', '']
    ]
    # rubocop:enable Metrics/LineLength
  end
end
