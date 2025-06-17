# frozen_string_literal: true

FactoryBot.define do
  factory :transcription_convention do
    convention_key { Faker::Lorem.characters(number: 10) }
    convention_text { Faker::Lorem.characters(number: 10) }
    example { Faker::Lorem.characters(number: 10) }
    institution
  end
end
