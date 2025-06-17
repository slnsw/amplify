# frozen_string_literal: true

RSpec.describe Theme, type: :model do
  # validations
  it { is_expected.to validate_presence_of(:name) }
end
