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

  describe '.getByLineForDisplay' do
    let(:transcript_line) { create(:transcript_line) }
    let!(:display_edit) { create(:transcript_edit, transcript_line: transcript_line, is_deleted: 0) }
    let!(:deleted_edit) { create(:transcript_edit, transcript_line: transcript_line, is_deleted: 1) }

    it 'returns non-deleted edits for display' do
      result = described_class.getByLineForDisplay(transcript_line.id)
      expect(result).to include(display_edit)
      expect(result).not_to include(deleted_edit)
    end
  end

  describe '.getByTranscript' do
    let(:transcript) { create(:transcript) }
    let!(:transcript_edit) { create(:transcript_edit, transcript: transcript, is_deleted: 0) }
    let!(:other_edit) { create(:transcript_edit, is_deleted: 0) }

    it 'returns non-deleted edits for the transcript' do
      result = described_class.getByTranscript(transcript.id)
      expect(result).to include(transcript_edit)
      expect(result).not_to include(other_edit)
    end
  end

  describe '.getByTranscriptSession' do
    let(:transcript) { create(:transcript) }
    let(:session_id) { 'test-session-123' }
    let!(:session_edit) { create(:transcript_edit, transcript: transcript, session_id: session_id, is_deleted: 0) }
    let!(:other_session_edit) do
      create(:transcript_edit, transcript: transcript, session_id: 'other-session', is_deleted: 0)
    end

    it 'returns non-deleted edits for the transcript and session' do
      result = described_class.getByTranscriptSession(transcript.id, session_id)
      expect(result).to include(session_edit)
      expect(result).not_to include(other_session_edit)
    end
  end

  describe '.getByTranscriptUser' do
    let(:transcript) { create(:transcript) }
    let(:user) { create(:user) }
    let!(:user_transcript_edit) { create(:transcript_edit, transcript: transcript, user_id: user.id, is_deleted: 0) }
    let!(:other_user_edit) { create(:transcript_edit, transcript: transcript, is_deleted: 0) }

    it 'returns non-deleted edits for the transcript and user' do
      result = described_class.getByTranscriptUser(transcript.id, user.id)
      expect(result).to include(user_transcript_edit)
      expect(result).not_to include(other_user_edit)
    end
  end

  describe '.updateUserSessions' do
    let!(:user_role) { create(:user_role, name: 'test_user_role') }
    let!(:target_user) { create(:user, lines_edited: 0, user_role: user_role, email: 'target@example.com') }
    let!(:temp_user) { create(:user, lines_edited: 0, user_role: user_role, email: 'temp@example.com') }
    let(:session_id) { 'session-456' }
    let!(:edit1) { create(:transcript_edit, session_id: session_id, user_id: temp_user.id) }
    let!(:edit2) { create(:transcript_edit, session_id: session_id, user_id: temp_user.id) }
    let!(:other_session_edit) { create(:transcript_edit, session_id: 'other-session', user_id: temp_user.id) }

    it 'updates user_id for all edits with the session_id' do
      described_class.updateUserSessions(session_id, target_user.id)
      expect(edit1.reload.user_id).to eq(target_user.id)
      expect(edit2.reload.user_id).to eq(target_user.id)
      expect(other_session_edit.reload.user_id).to eq(temp_user.id)
    end

    it 'increments user lines_edited count' do
      expect do
        described_class.updateUserSessions(session_id, target_user.id)
      end.to change { target_user.reload.lines_edited }.by(2)
    end

    context 'when no edits found for session' do
      it 'does not increment user lines_edited' do
        expect do
          described_class.updateUserSessions('nonexistent-session', target_user.id)
        end.not_to(change { target_user.reload.lines_edited })
      end
    end
  end
end
