# frozen_string_literal: true

RSpec.describe Theme, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
