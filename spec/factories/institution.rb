# frozen_string_literal: true
FactoryBot.define do
  factory :institution do
    # `institutions.name` is unique and Faker's university list is small enough
    # for two institutions built in one example to collide; the sequence keeps
    # every generated name distinct.
    sequence(:name) { |n| "#{Faker::University.name} #{n}" }
    url { 'http://google.com' }
    slug { Faker::Lorem.characters(number:10) }
  end
end
