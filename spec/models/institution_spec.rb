# frozen_string_literal: true

RSpec.describe Institution, type: :model do
  # associations
  it { is_expected.to have_many(:collections) }
  it { is_expected.to have_many(:users) }

  # validations
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to allow_value('correct-value').for(:slug) }
  it { is_expected.not_to allow_value('value with space').for(:slug) }

  context 'when an institution is first created' do
    let(:institution) { FactoryBot.build(:institution) }

    context 'when create_default' do
      it 'creates a transcript convention' do
        expect do
          institution.save
        end.to change { institution.transcription_conventions.count }.by(8)
      end
    end
  end

  context 'when saving a record' do
    subject(:save) do
      institution.min_lines_for_consensus = 4
      institution.save
      institution.reload
    end

    let(:institution) do
      FactoryBot.build(:institution,
                       max_line_edits: 0,
                       min_lines_for_consensus: 0,
                       min_lines_for_consensus_no_edits: 0)
    end

    it 'updates other configs' do
      save
      expect(institution.max_line_edits).to eq(4)
      expect(institution.min_lines_for_consensus_no_edits).to eq(4)
    end
  end

  describe 'institution links association' do
    let(:institution) { create(:institution) }

    context 'when they exist' do
      let!(:institution_link) { create(:institution_link, institution: institution) }

      it 'returns the association' do
        expect(institution.institution_links).to include(institution_link)
      end
    end

    context 'when they do not exist' do
      it 'returns a default list' do
        expect(institution.institution_links.pluck(:url)).to eq(Institution.default_links.pluck(:url))
      end
    end
  end
end
