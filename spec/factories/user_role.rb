# frozen_string_literal: true

FactoryBot.define do
  factory :user_role do
    sequence(:name) { |n| "role_#{n}" }
    hiearchy { 10 }
    description { 'Registered user' }

    trait :admin do
      name { 'admin' }
      hiearchy { 100 }
      description { 'Administrator has all privileges' }
    end

    trait :admin_with_admin_transcribing_role do
      name { 'admin' }
      transcribing_role { 'admin' }
      hiearchy { 100 }
      description { 'Administrator has all privileges' }
    end

    trait :admin_with_registed_user_transcribing_role do
      name { 'admin' }
      transcribing_role { 'registered_user' }
      hiearchy { 100 }
      description { 'Administrator has all privileges' }
    end

    trait :moderator do
      name { 'moderator' }
      hiearchy { 50 }
      description { 'Moderator can review edits' }
    end

    trait :content_editor do
      name { 'content_editor' }
      hiearchy { 50 }
      description { 'content_editor' }
    end
  end
end
