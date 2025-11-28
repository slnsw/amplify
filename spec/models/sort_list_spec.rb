# frozen_string_literal: true

RSpec.describe SortList do
  describe '.options' do
    it 'returns sorting options hash' do
      result = described_class.options
      expect(result).to be_a(Hash)
      expect(result).to include(
        title_asc: 'Title (A to Z)',
        title_desc: 'Title (Z to A)',
        percent_completed_desc: 'Completeness (most to least)'
      )
    end

    it 'includes all expected sort options' do
      result = described_class.options
      expect(result.keys).to contain_exactly(
        :title_asc,
        :title_desc,
        :percent_completed_desc,
        :percent_completed_asc,
        :duration_asc,
        :duration_desc
      )
    end
  end

  describe '.list' do
    it 'returns array of OpenStruct objects' do
      result = described_class.list
      expect(result).to be_an(Array)
      expect(result.first).to be_a(OpenStruct)
    end

    it 'converts options to OpenStruct with id and title' do
      result = described_class.list
      first_item = result.first
      expect(first_item.id).to eq(:title_asc)
      expect(first_item.title).to eq('Title (A to Z)')
    end

    it 'returns all options as OpenStruct objects' do
      result = described_class.list
      expect(result.size).to eq(6)
    end
  end
end
