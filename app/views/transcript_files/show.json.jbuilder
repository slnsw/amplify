# frozen_string_literal: true

json.id @transcript.uid
json.url transcript_url(@transcript)
json.origin_url @transcript.url if @transcript.url.present?
json.last_updated @transcript.updated_at
json.extract! @transcript, :title, :description, :audio_url, :image_url, :duration
json.lines @transcript.transcript_lines, :id, :sequence, :start_time, :end_time, :original_text, :best_text, :transcript_line_status_id, :speaker_id
json.speakers @transcript_speakers, :id, :name
json.statuses @transcript_line_statuses, :id, :name, :description
json.edits @transcript_edits, :transcript_line_id, :text, :created_at unless @transcript_edits.empty?
