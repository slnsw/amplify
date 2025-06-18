class TranscriptSpeaker < ApplicationRecord
  has_paper_trail
  belongs_to :speaker
  belongs_to :transcript

  def self.getByTranscriptId(transcript_id)
    Rails.cache.fetch("/transcript/#{transcript_id}/speakers", expires_in: 1.hour) do
      Speaker.joins(:transcript_speakers).where(transcript_speakers: { transcript_id: transcript_id })
    end
  end
end
