# frozen_string_literal: true

json.extract! admin_site_alert, :id, :machine_name, :message, :user_id, :published, :scheduled, :publish_at, :unpublish_at, :created_at, :updated_at
json.url admin_site_alert_url(admin_site_alert, format: :json)
