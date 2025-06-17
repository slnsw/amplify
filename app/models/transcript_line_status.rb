# frozen_string_literal: true

class TranscriptLineStatus < ApplicationRecord
  has_paper_trail

  def self.allCached
    Rails.cache.fetch('transcript_line_statuses', expires_in: 1.day) do
      TranscriptLineStatus.all
    end
  end
end
