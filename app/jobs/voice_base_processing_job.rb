class VoiceBaseProcessingJob < ApplicationJob
  queue_as :default

  def perform
    Transcript.voicebase_processing_pending.not_picked_up_for_voicebase_processing.find_each do |transcript|
      VoiceBase::VoicebaseApiService.check_progress(transcript.id)
      transcript = Transcript.find(transcript.id)
      VoiceBase::VoicebaseApiService.process_transcript(transcript.id)
    end
  end
end
