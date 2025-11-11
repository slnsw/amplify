# frozen_string_literal: true

RSpec.describe Flag, type: :model do
  it { is_expected.to belong_to :transcript_line }
  it { is_expected.to belong_to(:flag_type).optional }

  describe 'class methods' do
    describe '.getByLine' do
      let(:transcript_line) { create(:transcript_line) }
      let(:flag_type) { create(:flag_type, category: 'error') }
      let!(:flag) { create(:flag, transcript_line: transcript_line, flag_type: flag_type) }

      it 'returns flags for the given transcript line' do
        result = described_class.getByLine(transcript_line.id)
        expect(result).to include(flag)
      end
    end

    describe '.getByTranscriptSession' do
      let(:transcript) { create(:transcript) }
      let(:session_id) { 'test_session' }
      let!(:flag) { create(:flag, transcript_id: transcript.id, session_id: session_id, is_deleted: 0) }

      it 'returns non-deleted flags for the transcript and session' do
        result = described_class.getByTranscriptSession(transcript.id, session_id)
        expect(result).to include(flag)
      end
    end

    describe '.getByTranscriptUser' do
      let(:transcript) { create(:transcript) }
      let(:user) { create(:user) }
      let!(:flag) { create(:flag, transcript_id: transcript.id, user_id: user.id, is_deleted: 0) }

      it 'returns non-deleted flags for the transcript and user' do
        result = described_class.getByTranscriptUser(transcript.id, user.id)
        expect(result).to include(flag)
      end
    end

    describe '.pending_flags' do
      let(:institution) { create(:institution) }
      let(:collection) { create(:collection, institution: institution) }
      let(:transcript) { create(:transcript, collection: collection) }
      let(:transcript_line) { create(:transcript_line, transcript: transcript) }
      let(:flag_type) { create(:flag_type, category: 'error') }
      let!(:flag) do
        create(:flag,
               transcript_id: transcript.id,
               transcript_line: transcript_line,
               flag_type: flag_type,
               is_resolved: 0,
               is_deleted: 0)
      end

      context 'when institution_id is provided' do
        it 'returns pending flags for the institution' do
          result = described_class.pending_flags(institution.id)
          expect(result).to include(flag)
        end
      end

      context 'when institution_id is not provided' do
        it 'returns all pending flags' do
          result = described_class.pending_flags
          expect(result).to include(flag)
        end
      end
    end

    describe '.resolve' do
      let(:transcript_line) { create(:transcript_line) }
      let!(:flag) { create(:flag, transcript_line: transcript_line, is_resolved: 0) }

      it 'marks all flags for the transcript line as resolved' do
        expect { described_class.resolve(transcript_line.id) }
          .to change { flag.reload.is_resolved }.from(0).to(1)
      end
    end

    describe '.updateUserSessions' do
      let(:session_id) { 'test_session' }
      let(:new_user) { FactoryBot.create(:user) }
      let(:old_user) { FactoryBot.create(:user, :moderator) }
      let!(:flag) { FactoryBot.create(:flag, session_id: session_id, user_id: old_user.id) }

      it 'updates the user_id for all flags with the session_id' do
        expect { described_class.updateUserSessions(session_id, new_user.id) }
          .to change { flag.reload.user_id }.from(old_user.id).to(new_user.id)
      end
    end
  end
end
