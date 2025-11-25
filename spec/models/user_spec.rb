# frozen_string_literal: true

RSpec.describe User, type: :model do
  it { is_expected.to belong_to(:institution).optional }
  it { is_expected.to belong_to(:user_role).optional }

  describe 'scopes' do
    let(:admin_role) { create(:user_role, :admin, id: 5) }
    let(:registered_user_role) { create(:user_role, id: 2) }
    let!(:admin_user) { create(:user, user_role: admin_role) }
    let!(:registered_user) { create(:user, user_role: registered_user_role) }

    describe '.only_staff_users' do
      it 'includes staff users' do
        expect(described_class.only_staff_users).to include(admin_user)
      end

      it 'excludes non-staff users' do
        expect(described_class.only_staff_users).not_to include(registered_user)
      end
    end

    describe '.only_public_users' do
      it 'includes public users' do
        expect(described_class.only_public_users).to include(registered_user)
      end

      it 'excludes staff users' do
        expect(described_class.only_public_users).not_to include(admin_user)
      end
    end
  end

  describe 'class methods' do
    describe '.orderByInstitution' do
      let(:registered_user_role) { create(:user_role, id: 2) }
      let(:australian_war_memorial) { create(:institution, name: 'Australian War Memorial') }
      let(:state_library_qld) { create(:institution, name: 'State Library of Queensland') }
      let(:wollongong_libraries) { create(:institution, name: 'Wollongong City Libraries') }
      let!(:user_without_institution) { create(:user, user_role: registered_user_role, institution: nil) }
      let!(:user_with_awm) { create(:user, user_role: registered_user_role, institution: australian_war_memorial) }
      let!(:user_with_slq) { create(:user, user_role: registered_user_role, institution: state_library_qld) }
      let!(:user_with_woll) { create(:user, user_role: registered_user_role, institution: wollongong_libraries) }

      it 'orders users by institution name in ascending order' do
        expect(described_class.orderByInstitution)
          .to eq([user_without_institution, user_with_awm, user_with_slq, user_with_woll])
      end

      it 'puts users without institutions first' do
        expect(described_class.orderByInstitution.first.institution).to be_nil
      end

      it 'orders remaining users alphabetically by institution name' do
        expect(described_class.orderByInstitution.last.institution.name).to eq(wollongong_libraries.name)
      end
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }

    describe '#incrementLinesEdited' do
      context 'when called with default amount' do
        it 'increments lines_edited by 1' do
          expect { user.incrementLinesEdited }
            .to change { user.reload.lines_edited }.by(1)
        end
      end

      context 'when called with custom amount' do
        it 'increments lines_edited by the specified amount' do
          expect { user.incrementLinesEdited(5) }
            .to change { user.reload.lines_edited }.by(5)
        end
      end
    end

    describe '#setRole' do
      let(:admin_role) { create(:user_role, name: 'admin') }

      context 'when role exists and is different' do
        it 'updates the user role' do
          expect { user.setRole('admin') }
            .to change { user.reload.user_role_id }.to(admin_role.id)
        end
      end

      context 'when role is the same' do
        let(:user) { create(:user, user_role: admin_role) }

        it 'does not update the user role' do
          expect { user.setRole('admin') }
            .not_to(change { user.reload.updated_at })
        end
      end
    end

    describe '#admin?' do
      context 'when user has admin role' do
        let(:admin_role) { create(:user_role, name: 'admin') }
        let(:user) { create(:user, user_role: admin_role) }

        it 'returns true' do
          expect(user.admin?).to be true
        end
      end

      context 'when user does not have admin role' do
        it 'returns false' do
          expect(user.admin?).to be false
        end
      end
    end

    describe '#moderator?' do
      context 'when user has moderator role' do
        let(:moderator_role) { create(:user_role, name: 'moderator') }
        let(:user) { create(:user, user_role: moderator_role) }

        it 'returns true' do
          expect(user.moderator?).to be true
        end
      end

      context 'when user does not have moderator role' do
        it 'returns false' do
          expect(user.moderator?).to be false
        end
      end
    end

    describe '#content_editor?' do
      context 'when user has content_editor role' do
        let(:content_editor_role) { create(:user_role, name: 'content_editor') }
        let(:user) { create(:user, user_role: content_editor_role) }

        it 'returns true' do
          expect(user.content_editor?).to be true
        end
      end

      context 'when user does not have content_editor role' do
        it 'returns false' do
          expect(user.content_editor?).to be false
        end
      end
    end

    describe '#recalculate' do
      let(:user) { create(:user) }
      let(:transcript) { create(:transcript) }
      let(:transcript_line) { create(:transcript_line, transcript: transcript) }
      let!(:edit1) do
        create(:transcript_edit, user_id: user.id, transcript: transcript, transcript_line: transcript_line)
      end
      let!(:edit2) do
        create(:transcript_edit, user_id: user.id, transcript: transcript, transcript_line: transcript_line)
      end

      it 'updates lines_edited count' do
        expect { user.recalculate }
          .to change { user.reload.lines_edited }.to(2)
      end
    end

    describe '#isAdmin?' do
      context 'when user has admin role' do
        let(:admin_role) { create(:user_role, name: 'admin') }
        let(:user) { create(:user, user_role: admin_role) }

        it 'returns true (deprecated method)' do
          expect(user.isAdmin?).to be true
        end
      end
    end
  end
end
