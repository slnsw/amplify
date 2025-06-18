module UpdateMultipleTranscriptsConcern
  extend ActiveSupport::Concern

  def publish_trancripts(transcript_ids)
    @collection.transcripts.where(uid: transcript_ids).find_each(&:publish!)
    flash.now[:notice] = "The selected transcripts were successfully published!"
  end

  def unpublish_trancripts(transcript_ids)
    @collection.transcripts.where(uid: transcript_ids).find_each(&:unpublish!)
    flash.now[:notice] = "The selected transcripts were successfully unpublished!"
  end

  def delete_trancripts(transcript_ids)
    @collection.transcripts.where(uid: transcript_ids).find_each(&:destroy)
    flash.now[:notice] = "The selected transcripts were successfully deleted!"
  end
end
