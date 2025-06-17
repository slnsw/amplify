# frozen_string_literal: true

class RecalculateTranscriptsJob < ApplicationJob
  queue_as :default

  def perform
    Transcript.order(updated_at: :desc).limit(250).each(&:recalculate)
  end
end
