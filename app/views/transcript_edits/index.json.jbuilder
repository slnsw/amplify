# frozen_string_literal: true

json.edits @transcript_edits, :id, :transcript_id, :transcript_line_id, :text, :updated_at
json.transcripts @transcripts do |transcript|
  json.extract! transcript, :id, :title, :description, :image_url
  json.path transcript_path(transcript)
end
