# frozen_string_literal: true

class VoiceBaseUploadJob < ApplicationJob
  queue_as :default

  def perform(transcript_id)
    VoiceBase::VoicebaseApiService.upload_media(transcript_id)
  end
end
