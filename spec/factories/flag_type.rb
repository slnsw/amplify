# frozen_string_literal: true

FactoryBot.define do
  factory :flag_type do
    name { Faker::Color.color_name }
    label { Faker::Lorem.word }
    description { Faker::Lorem.word }
    category { 'error' }
  end
end
