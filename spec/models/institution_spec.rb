# frozen_string_literal: true

RSpec.describe Institution, type: :model do
  it { is_expected.to have_many(:collections).dependent(:destroy) }
  it { is_expected.to have_many(:transcription_conventions).dependent(:destroy) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:institution_links).dependent(:destroy) }
  it { is_expected.to have_many(:transcripts).through(:collections) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_numericality_of(:min_lines_for_consensus) }
  it { is_expected.to allow_value('correct-value').for(:slug) }
  it { is_expected.not_to allow_value('value with space').for(:slug) }

  describe 'class methods' do
    describe '.state_library_nsw' do
      let!(:slnsw) { create(:institution, name: 'State Library of New South Wales') }

      it 'returns the State Library of New South Wales institution' do
        expect(described_class.state_library_nsw).to eq(slnsw)
      end
    end

    describe '.all_institution_disk_usage' do
      it 'returns aggregated disk usage statistics' do
        result = described_class.all_institution_disk_usage
        expect(result).to have_key(:image)
        expect(result).to have_key(:audio)
        expect(result).to have_key(:script)
      end
    end
  end

  describe 'instance methods' do
    describe '#institution_links' do
      let(:institution) { create(:institution) }

      context 'when institution has custom links' do
        let!(:institution_link) { create(:institution_link, institution: institution) }

        it 'returns the custom links' do
          expect(institution.institution_links).to include(institution_link)
        end
      end

      context 'when institution has no custom links' do
        it 'returns the default links' do
          expect(institution.institution_links.pluck(:url)).to eq(described_class.default_links.pluck(:url))
        end
      end
    end

    describe '#published_transcripts' do
      let(:institution) { create(:institution) }
      let(:collection) { create(:collection, institution: institution, published_at: Time.current) }
      let!(:transcript) { create(:transcript, collection: collection, published_at: Time.current) }

      it 'returns published transcripts from published collections' do
        expect(institution.published_transcripts).to include(transcript)
      end
    end

    describe '#should_generate_new_friendly_id?' do
      let(:institution) { create(:institution) }

      it 'returns false' do
        expect(institution.should_generate_new_friendly_id?).to be false
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      let(:institution) { build(:institution) }

      it 'creates default transcription conventions' do
        expect { institution.save }
          .to change { institution.transcription_conventions.count }.by(8)
      end
    end

    describe 'before_save with min_lines_for_consensus' do
      let(:institution) do
        build(:institution,
              max_line_edits: 0,
              min_lines_for_consensus: 4,
              min_lines_for_consensus_no_edits: 0)
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'sets consensus-related attributes' do
        institution.save
        institution.reload
        expect(institution.max_line_edits).to eq(4)
        expect(institution.min_lines_for_consensus_no_edits).to eq(4)
        expect(institution.min_percent_consensus).to eq(4.0 / 5.0)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    describe 'before_save guid generation' do
      let(:institution) { build(:institution, guid: nil) }

      it 'generates a guid if not present' do
        expect { institution.save }
          .to change(institution, :guid).from(nil).to(a_string_matching(/\A[0-9a-f-]{36}\z/))
      end
    end
  end
end
