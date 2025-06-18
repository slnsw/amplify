RSpec.describe PublicPage, type: :model do
  # associations
  it { is_expected.to belong_to(:page) }
end
