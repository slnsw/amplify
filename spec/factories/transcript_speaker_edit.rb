# frozen_string_literal: true

FactoryBot.define do
  factory :transcript_speaker_edit do
    transcript
    speaker
    session_id { Faker::Crypto.md5 }
  end
end
