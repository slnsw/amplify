# frozen_string_literal: true

FactoryBot.define do
  factory :public_page do
    page
    content { 'MyString' }
  end
end
