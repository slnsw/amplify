# frozen_string_literal: true

FactoryBot.define do
  factory :institution_link do
    institution
    title { 'MyString' }
    url { 'MyString' }
    position { 1 }
  end
end
