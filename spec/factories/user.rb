FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    uid { "12345678" }
    name { Faker::Name.name }
    nickname { Faker::Name.initials }
    email { Faker::Internet.email }
    lines_edited { 0 }
    password { "Password123" }
    confirmed_at { Time.zone.now }
    association :user_role, factory: :user_role

    trait :admin do
      association :user_role, factory: [:user_role, :admin]
    end

    trait :admin_with_admin_transcribing_role do
      association :user_role, factory: [:user_role, :admin_with_admin_transcribing_role]
    end

    trait :admin_with_registed_user_transcribing_role do
      association :user_role, factory: [:user_role, :admin_with_registed_user_transcribing_role]
    end

    trait :moderator do
      association :user_role, factory: [:user_role, :moderator]
    end

    trait :content_editor do
      association :user_role, factory: [:user_role, :content_editor]
    end
  end
end
