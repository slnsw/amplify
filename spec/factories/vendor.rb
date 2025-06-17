# frozen_string_literal: true

FactoryBot.define do
  factory :vendor do
    uid { Faker::Lorem.characters(number: 10) }
    name { 'VoiceBase' }
  end
end
