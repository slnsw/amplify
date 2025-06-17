# frozen_string_literal: true

json.entries @transcripts do |transcript|
  json.extract! transcript, :uid, :title, :description, :image_url, :collection_id, :collection_title, :duration, :percent_completed
  json.path transcript_path(transcript)
end
