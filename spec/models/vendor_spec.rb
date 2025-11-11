# frozen_string_literal: true

RSpec.describe Vendor, type: :model do
  it { is_expected.to have_many(:collections) }
  it { is_expected.to have_many(:transcripts) }
  it { is_expected.to be_versioned }
end
