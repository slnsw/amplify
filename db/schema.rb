# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_30_160961) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "app_configs", force: :cascade do |t|
    t.string "app_name"
    t.boolean "show_theme", default: false
    t.boolean "show_institutions", default: false
    t.string "image"
    t.string "main_title"
    t.string "intro_title"
    t.text "intro_text"
  end

  create_table "cms_image_uploads", force: :cascade do |t|
    t.string "image"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "collections", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "image_url"
    t.integer "vendor_id", default: 0, null: false
    t.string "vendor_identifier", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_uid", default: "", null: false
    t.datetime "published_at"
    t.string "image"
    t.string "library_catalogue_title", default: ""
    t.integer "institution_id"
    t.string "collection_url_title", default: " View in Library catalogue"
    t.boolean "publish", default: false
    t.integer "max_line_edits"
    t.integer "min_lines_for_consensus"
    t.integer "min_lines_for_consensus_no_edits"
    t.decimal "min_percent_consensus"
    t.index ["project_uid"], name: "index_collections_on_project_uid"
    t.index ["uid"], name: "index_collections_on_uid", unique: true
    t.index ["vendor_id"], name: "index_collections_on_vendor_id"
  end

  create_table "flag_types", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "label", default: "", null: false
    t.string "description", default: "", null: false
    t.string "category", default: "", null: false
    t.index ["category"], name: "index_flag_types_on_category"
    t.index ["name"], name: "index_flag_types_on_name", unique: true
  end

  create_table "flags", force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.integer "flag_type_id", default: 0, null: false
    t.string "text", default: "", null: false
    t.integer "is_deleted", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_resolved", default: 0, null: false
    t.index ["transcript_id"], name: "index_flags_on_transcript_id"
    t.index ["transcript_line_id"], name: "index_flags_on_transcript_line_id"
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "institution_links", force: :cascade do |t|
    t.bigint "institution_id"
    t.string "title"
    t.string "url"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["institution_id"], name: "index_institution_links_on_institution_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.string "url"
    t.string "image"
    t.string "hero_image"
    t.text "introductory_text"
    t.integer "max_line_edits", default: 3
    t.integer "min_lines_for_consensus", default: 3
    t.integer "min_lines_for_consensus_no_edits", default: 3
    t.decimal "min_percent_consensus", default: "0.67"
    t.string "line_display_method", default: "guess"
    t.integer "super_user_hiearchy", default: 50
    t.boolean "hidden", default: false
    t.string "guid"
    t.index ["slug"], name: "index_institutions_on_slug"
  end

  create_table "pages", force: :cascade do |t|
    t.text "content"
    t.string "page_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "published", default: false
    t.boolean "admin_access", default: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "public_pages", force: :cascade do |t|
    t.integer "page_id"
    t.string "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "seed_migration_data_migrations", force: :cascade do |t|
    t.string "version"
    t.integer "runtime"
    t.datetime "migrated_on"
  end

  create_table "site_alerts", force: :cascade do |t|
    t.string "machine_name", null: false
    t.string "level", default: "status", null: false
    t.text "message"
    t.integer "user_id", default: 0, null: false
    t.boolean "published", default: false
    t.boolean "admin_access", default: false
    t.boolean "scheduled", default: false
    t.datetime "publish_at", precision: nil
    t.datetime "unpublish_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["machine_name"], name: "index_site_alerts_on_machine_name", unique: true
  end

  create_table "speakers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_themes_on_name"
  end

  create_table "transcript_edits", force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.string "text"
    t.integer "weight", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "is_deleted", default: 0, null: false
    t.index ["session_id", "transcript_line_id"], name: "index_transcript_edits_on_session_id_and_transcript_line_id", unique: true
    t.index ["session_id"], name: "index_transcript_edits_on_session_id"
    t.index ["transcript_id"], name: "index_transcript_edits_on_transcript_id"
    t.index ["transcript_line_id"], name: "index_transcript_edits_on_transcript_line_id"
    t.index ["user_id"], name: "index_transcript_edits_on_user_id"
  end

  create_table "transcript_line_statuses", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "progress", default: 0, null: false
    t.string "description"
    t.index ["name"], name: "index_transcript_line_statuses_on_name", unique: true
  end

  create_table "transcript_lines", force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "start_time", default: 0, null: false
    t.integer "end_time", default: 0, null: false
    t.integer "speaker_id", default: 0, null: false
    t.string "original_text", default: "", null: false
    t.string "text", default: "", null: false
    t.integer "sequence", default: 0, null: false
    t.integer "transcript_line_status_id", default: 1, null: false
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guess_text", default: "", null: false
    t.integer "flag_count", default: 0, null: false
    t.index ["speaker_id"], name: "index_transcript_lines_on_speaker_id"
    t.index ["transcript_id", "sequence"], name: "index_transcript_lines_on_transcript_id_and_sequence", unique: true
    t.index ["transcript_id"], name: "index_transcript_lines_on_transcript_id"
    t.index ["transcript_line_status_id"], name: "index_transcript_lines_on_transcript_line_status_id"
  end

  create_table "transcript_speaker_edits", force: :cascade do |t|
    t.integer "transcript_id", default: 0, null: false
    t.integer "transcript_line_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "session_id", default: "", null: false
    t.integer "speaker_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "transcript_line_id"], name: "index_transcript_speaker_edits_on_session_id_and_line_id", unique: true
    t.index ["transcript_line_id"], name: "index_transcript_speaker_edits_on_transcript_line_id"
    t.index ["user_id"], name: "index_transcript_speaker_edits_on_user_id"
  end

  create_table "transcript_speakers", force: :cascade do |t|
    t.integer "speaker_id", default: 0, null: false
    t.integer "transcript_id", default: 0, null: false
    t.integer "collection_id", default: 0, null: false
    t.string "project_uid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaker_id", "transcript_id"], name: "index_transcript_speakers_on_speaker_id_and_transcript_id", unique: true
  end

  create_table "transcript_statuses", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "progress", default: 0, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_transcript_statuses_on_name", unique: true
  end

  create_table "transcription_conventions", force: :cascade do |t|
    t.string "convention_key"
    t.string "convention_text"
    t.string "example"
    t.integer "institution_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "transcripts", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "audio_url"
    t.string "image_url"
    t.integer "collection_id", default: 0, null: false
    t.integer "vendor_id", default: 0, null: false
    t.string "vendor_identifier", default: "", null: false
    t.integer "duration", default: 0, null: false
    t.integer "lines", default: 0, null: false
    t.text "notes"
    t.integer "transcript_status_id", default: 1, null: false
    t.integer "order", default: 0, null: false
    t.integer "created_by", default: 0, null: false
    t.string "batch_id", default: "unknown", null: false
    t.datetime "transcript_retrieved_at"
    t.datetime "transcript_processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "vendor_audio_urls", default: "[]", null: false
    t.string "project_uid", default: "", null: false
    t.integer "percent_completed", default: 0, null: false
    t.integer "lines_completed", default: 0, null: false
    t.integer "percent_edited", default: 0, null: false
    t.integer "lines_edited", default: 0, null: false
    t.integer "is_published", default: 1, null: false
    t.integer "percent_reviewing", default: 0, null: false
    t.integer "lines_reviewing", default: 0, null: false
    t.integer "users_contributed", default: 0, null: false
    t.integer "can_download", default: 1, null: false
    t.string "image"
    t.string "audio"
    t.string "script"
    t.string "image_caption", default: ""
    t.string "image_catalogue_url", default: ""
    t.datetime "published_at", precision: nil
    t.string "audio_item_url_title", default: "View audio in Library catalogue"
    t.string "image_item_url_title", default: "View image in Library catalogue"
    t.boolean "publish", default: false
    t.integer "transcript_type", default: 0
    t.string "voicebase_media_id"
    t.string "process_status"
    t.datetime "process_completed_at", precision: nil
    t.datetime "process_started_at", precision: nil
    t.integer "crop_x"
    t.integer "crop_y"
    t.integer "crop_w"
    t.integer "crop_h"
    t.string "process_message"
    t.index ["collection_id"], name: "index_transcripts_on_collection_id"
    t.index ["duration"], name: "index_transcripts_on_duration"
    t.index ["project_uid"], name: "index_transcripts_on_project_uid"
    t.index ["transcript_status_id"], name: "index_transcripts_on_transcript_status_id"
    t.index ["uid"], name: "index_transcripts_on_uid", unique: true
    t.index ["vendor_id"], name: "index_transcripts_on_vendor_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "hiearchy", default: 0, null: false
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "transcribing_role", default: "registered_user"
    t.index ["name"], name: "index_user_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_role_id", default: 0, null: false
    t.integer "lines_edited", default: 0, null: false
    t.integer "institution_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "name"
    t.string "description"
    t.string "url"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_vendors_on_uid", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
