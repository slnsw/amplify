# frozen_string_literal: true

json.extract! admin_institution, :id, :name, :created_at, :updated_at
json.url admin_institution_url(admin_institution, format: :json)
