# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    name { Faker::University.name }
    url { 'http://google.com' }
    slug { Faker::Lorem.characters(number: 10) }
  end
end
