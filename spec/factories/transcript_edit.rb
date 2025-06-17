# frozen_string_literal: true

FactoryBot.define do
  factory :transcript_edit do
    transcript
    transcript_line
    user_id { 1 }
    text { Faker::Lorem.sentence }
    session_id { Faker::Crypto.md5 }
  end
end
