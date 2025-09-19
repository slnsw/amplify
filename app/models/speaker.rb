class Speaker < ApplicationRecord
  has_paper_trail
  has_many :transcript_speakers
end
