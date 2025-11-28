# frozen_string_literal: true

RSpec.describe InstitutionLink, type: :model do
  it { is_expected.to belong_to(:institution) }
  it { is_expected.to validate_presence_of(:position) }
end
