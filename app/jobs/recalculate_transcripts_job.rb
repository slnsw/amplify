class RecalculateTranscriptsJob < ApplicationJob
  queue_as :default

  def perform
    Transcript.order(updated_at: :desc).limit(250).each do |transcript|
      transcript.recalculate
    end
  end
end
