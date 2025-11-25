# frozen_string_literal: true

RSpec.describe UserRolePolicy do
  describe 'Scope' do
    let!(:admin_role) { create(:user_role, name: 'admin') }
    let!(:moderator_role) { create(:user_role, name: 'moderator') }
    let!(:content_editor_role) { create(:user_role, name: 'content_editor') }
    let!(:user_role) { create(:user_role, name: 'user') }
    let!(:guest_role) { create(:user_role, name: 'guest') }

    context 'when user is admin' do
      let(:admin_user) { create(:user, user_role: admin_role) }

      it 'returns all user roles' do
        policy_scope = UserRolePolicy::Scope.new(admin_user, UserRole).resolve
        expect(policy_scope.count).to eq(5)
      end
    end

    context 'when user is moderator' do
      let(:moderator_user) { create(:user, user_role: moderator_role) }

      it 'returns only moderator role' do
        policy_scope = UserRolePolicy::Scope.new(moderator_user, UserRole).resolve
        expect(policy_scope).to eq([moderator_role])
      end
    end

    context 'when user is content_editor' do
      let(:content_editor_user) { create(:user, user_role: content_editor_role) }

      it 'returns guest, user, moderator, and content_editor roles' do
        policy_scope = UserRolePolicy::Scope.new(content_editor_user, UserRole).resolve
        expect(policy_scope).to include(guest_role, user_role, moderator_role, content_editor_role)
        expect(policy_scope).not_to include(admin_role)
      end
    end

    context 'when user has other role' do
      let(:regular_user) { create(:user, user_role: user_role) }

      it 'returns no roles' do
        policy_scope = UserRolePolicy::Scope.new(regular_user, UserRole).resolve
        expect(policy_scope).to eq([])
      end
    end
  end
end
