# frozen_string_literal: true

FactoryBot.define do
  factory :transcript_line do
    transcript
    start_time { 2980 }
    end_time { 6850 }
    original_text { Faker::Lorem.sentence }
  end
end
