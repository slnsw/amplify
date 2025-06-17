# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.configure do |config|
  config.around(:each, sidekiq: true) do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end
end
