# frozen_string_literal: true

FactoryBot.define do
  factory :transcript_speaker do
    transcript
    speaker
    collection
  end
end
