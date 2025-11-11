# frozen_string_literal: true

RSpec.describe TranscriptSpeakerEdit, type: :model do
  it { is_expected.to belong_to(:transcript_line) }
  it { is_expected.to belong_to(:transcript) }
  it { is_expected.to validate_presence_of(:session_id) }
  it { is_expected.to validate_presence_of(:transcript_id) }
  it { is_expected.to validate_numericality_of(:transcript_id).only_integer }
  it { is_expected.to validate_presence_of(:transcript_line_id) }
  it { is_expected.to validate_numericality_of(:transcript_line_id).only_integer }
  it { is_expected.to validate_presence_of(:speaker_id) }
  it { is_expected.to validate_numericality_of(:speaker_id).only_integer }
  it { is_expected.to be_versioned }

  describe '.getByLine' do
    let(:transcript_line) { create(:transcript_line) }
    let!(:edit1) { create(:transcript_speaker_edit, transcript_line: transcript_line) }
    let!(:edit2) { create(:transcript_speaker_edit, transcript_line: transcript_line) }
    let!(:other_edit) { create(:transcript_speaker_edit) }

    it 'returns edits for the line' do
      result = described_class.getByLine(transcript_line.id)
      expect(result.map(&:id)).to include(edit1.id, edit2.id)
      expect(result.map(&:id)).not_to include(other_edit.id)
    end
  end
end
