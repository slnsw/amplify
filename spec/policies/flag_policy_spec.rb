require 'rails_helper'

RSpec.describe FlagPolicy do
  let(:user) { create(:user) }
  let(:scope) { Flag } # Assuming you have a Flag model

  subject { described_class }

  describe "#initialize" do
    it "assigns user and scope" do
      policy = subject.new(user, scope)
      expect(policy.user).to eq(user)
      expect(policy.scope).to eq(scope)
    end
  end
end
