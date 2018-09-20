FactoryBot.define do
  factory :transcript do
    uid { Faker::Lorem.characters(10) }
    title { Faker::Lorem.sentence }
    description "Faith Bandler interviewed by Carol"
    audio_url "http://google.com"
    collection
    vendor
    project_uid 'nsw-state-library-amplify'

    trait :published do
      publish 1
    end
  end
end
