# frozen_string_literal: true

json.extract! @transcript, :id, :uid, :title, :description, :url, :audio_url, :image_cropped_thumb_url, :image_caption, :image_catalogue_url, :duration, :lines, :notes, :vendor_audio_urls, :percent_completed, :percent_edited, :percent_reviewing, :lines_completed, :lines_edited, :lines_reviewing, :users_contributed, :can_download,
              :audio_item_url_title,
              :image_item_url_title, :published_at

unless @transcript.transcript_status.nil?
  json.transcript_status @transcript.transcript_status, :id, :name, :progress, :description
end

collection = @transcript.collection

unless collection.nil?
  json.collection collection, :id, :uid, :title, :description, :url, :image_url,
                  :collection_url_title
  json.institution collection.institution, :id, :name
end

json.lines @transcript.transcript_lines, :id, :start_time, :end_time, :original_text, :text, :guess_text, :sequence, :transcript_line_status_id, :speaker_id, :flag_count

json.speakers @transcript_speakers, :id, :name

json.transcript_line_statuses @transcript_line_statuses, :id, :name, :progress, :description

json.user_edits @user_edits, :transcript_line_id, :text, :updated_at

json.flag_types @flag_types, :id, :name, :label, :description

json.user_flags @user_flags, :transcript_line_id, :flag_type_id, :text

json.user_role @user_role, :id, :name, :hiearchy unless @user_role.nil?

unless @transcription_conventions.nil?
  json.conventions @transcription_conventions, :convention_key, :convention_text, :example
end
json.instructions @instructions, :content
