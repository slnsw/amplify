FactoryBot.define do
  factory :speaker do
    name { Faker::Lorem.characters(number: 10) }
  end
end
