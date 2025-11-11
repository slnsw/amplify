# frozen_string_literal: true

RSpec.describe TranscriptionConvention, type: :model do
  it { is_expected.to belong_to(:institution) }
  it { is_expected.to be_versioned }

  describe '.default_list' do
    it 'returns array of default conventions' do
      result = described_class.default_list
      expect(result).to be_an(Array)
      expect(result.first).to be_an(Array)
      expect(result.first.size).to eq(3)
    end

    it 'includes expected convention types' do
      result = described_class.default_list
      convention_keys = result.map(&:first)
      expect(convention_keys).to include(
        'Language',
        'Contractions',
        'Numbers',
        'Filled Pauses & Hesitations'
      )
    end

    it 'has 8 default conventions' do
      expect(described_class.default_list.size).to eq(8)
    end
  end

  describe '.create_default' do
    let(:institution) { create(:institution) }

    it 'creates default conventions for institution' do
      expect { described_class.create_default(institution.id) }
        .to change { described_class.where(institution_id: institution.id).count }.by(8)
    end

    it 'sets convention_key for each convention' do
      described_class.create_default(institution.id)
      conventions = described_class.where(institution_id: institution.id)
      expect(conventions.pluck(:convention_key)).to include('Language', 'Contractions', 'Numbers')
    end

    it 'sets convention_text for each convention' do
      described_class.create_default(institution.id)
      conventions = described_class.where(institution_id: institution.id)
      expect(conventions.pluck(:convention_text).compact).not_to be_empty
    end
  end
end
