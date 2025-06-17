# frozen_string_literal: true

RSpec.describe PublicPage, type: :model do
  # associations
  it { should belong_to(:page) }
end
