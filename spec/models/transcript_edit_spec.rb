# frozen_string_literal: true

RSpec.describe TranscriptEdit, type: :model do
  it { is_expected.to belong_to(:transcript) }
  it { is_expected.to belong_to(:transcript_line) }
  it { is_expected.to validate_presence_of(:session_id) }
  it { is_expected.to validate_presence_of(:transcript_id) }
  it { is_expected.to validate_numericality_of(:transcript_id).only_integer }
  it { is_expected.to validate_presence_of(:transcript_line_id) }
  it { is_expected.to validate_numericality_of(:transcript_line_id).only_integer }
  it { is_expected.to validate_numericality_of(:is_deleted).only_integer }
  it { is_expected.to be_versioned }

  describe '#normalizedText' do
    let(:edit) { build(:transcript_edit, text: 'Hello, World! Uhm... This is a TEST.') }

    it 'downcases the text' do
      result = edit.normalizedText
      expect(result).not_to match(/[A-Z]/)
    end

    it 'removes punctuation' do
      result = edit.normalizedText
      expect(result).not_to include(',', '.', '!')
    end

    it 'removes filler words like uhm' do
      result = edit.normalizedText
      expect(result).not_to include('uhm')
    end

    it 'removes extra whitespace' do
      result = edit.normalizedText
      expect(result).not_to match(/\s{2,}/)
    end

    it 'trims the text' do
      result = edit.normalizedText
      expect(result).to eq(result.strip)
    end
  end

  describe '.getByLine' do
    let(:transcript_line) { create(:transcript_line) }
    let!(:edit1) { create(:transcript_edit, transcript_line: transcript_line, is_deleted: 0) }
    let!(:edit2) { create(:transcript_edit, transcript_line: transcript_line, is_deleted: 0) }
    let!(:deleted_edit) { create(:transcript_edit, transcript_line: transcript_line, is_deleted: 1) }

    it 'returns non-deleted edits for the line' do
      result = described_class.getByLine(transcript_line.id)
      expect(result).to include(edit1, edit2)
      expect(result).not_to include(deleted_edit)
    end
  end

  describe '.getByUser' do
    let(:user) { create(:user) }
    let!(:user_edit) { create(:transcript_edit, user_id: user.id, is_deleted: 0) }
    let!(:other_edit) { create(:transcript_edit, is_deleted: 0) }

    it 'returns non-deleted edits for the user' do
      result = described_class.getByUser(user.id)
      expect(result).to include(user_edit)
      expect(result).not_to include(other_edit)
    end
  end

  describe '.getStatsByDay' do
    it 'caches the result for 10 minutes' do
      allow(Rails.cache).to receive(:fetch).and_call_original
      described_class.getStatsByDay
      expect(Rails.cache).to have_received(:fetch)
        .with("#{ENV.fetch('PROJECT_ID', nil)}/transcript_edits/stats", expires_in: 10.minutes)
    end
  end
end
