# frozen_string_literal: true

RSpec.describe FlagType, type: :model do
  it { is_expected.to be_versioned }

  describe '.byCategory' do
    let(:category) { 'test_category' }
    let!(:flag_type1) { create(:flag_type, category: category, name: 'Flag 1') }
    let!(:flag_type2) { create(:flag_type, category: category, name: 'Flag 2') }
    let!(:other_flag_type) { create(:flag_type, category: 'other', name: 'Flag 3') }

    it 'returns flag types for the given category' do
      result = described_class.byCategory(category)
      expect(result).to include(flag_type1, flag_type2)
      expect(result).not_to include(other_flag_type)
    end

    it 'caches the result for 1 day' do
      allow(Rails.cache).to receive(:fetch).and_call_original
      described_class.byCategory(category)
      expect(Rails.cache).to have_received(:fetch)
        .with("flag_types/#{category}", expires_in: 1.day)
    end
  end
end
