# frozen_string_literal: true

FactoryBot.define do
  factory :transcript_status do
    name { 'in_progress' }
    description { 'Transcript is currently being processed.' }
  end
end
