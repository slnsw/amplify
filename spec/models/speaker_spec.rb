# frozen_string_literal: true

RSpec.describe Speaker, type: :model do
  it { is_expected.to have_many(:transcript_speakers) }
  it { is_expected.to be_versioned }
end
