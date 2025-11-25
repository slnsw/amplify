# frozen_string_literal: true

RSpec.describe FlagPolicy do
  let(:user) { create(:user) }
  let(:flag) { create(:flag) }
  let(:policy) { described_class.new(user, flag) }

  describe '#initialize' do
    it 'sets user and scope' do
      expect(policy.user).to eq(user)
      expect(policy.scope).to eq(flag)
    end
  end
end
