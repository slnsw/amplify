FactoryBot.define do
  factory :collection do
    uid { Faker::Lorem.characters(number:10) }
    title { Faker::Lorem.sentence }
    description { "Faith Bandler interviewed by Carol" }
    url { Faker::Internet.url }
    image_url { "https://slnsw-amplify.s3.amazonaws.com/image.jpg" }
    project_uid { "nsw-state-library-amplify" }
    vendor_identifier { "col_vendor_id" }
    institution
    vendor
    publish { 1 }

    trait :published do
      publish { 1 }
    end

    trait :unpublished do
      publish { 0 }
    end
  end
end
