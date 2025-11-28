# frozen_string_literal: true

RSpec.describe PublicPage, type: :model do
  it { is_expected.to belong_to(:page) }
end
