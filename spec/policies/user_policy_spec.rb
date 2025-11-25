# frozen_string_literal: true

RSpec.describe UserPolicy do
  let(:institution) { create(:institution) }
  let(:other_institution) { create(:institution) }

  describe 'Scope' do
    let(:admin_role) { create(:user_role, :admin) }
    let(:content_editor_role) { create(:user_role, :content_editor) }
    let(:regular_role) { create(:user_role, name: 'regular_user', hiearchy: 1) }
    let!(:admin_user) { create(:user, user_role: admin_role, institution: institution) }
    let!(:content_editor) { create(:user, user_role: content_editor_role, institution: institution) }
    let!(:regular_user) { create(:user, user_role: regular_role, institution: institution) }
    let!(:other_institution_user) { create(:user, user_role: regular_role, institution: other_institution) }

    context 'when user is admin' do
      it 'returns all users' do
        policy_scope = UserPolicy::Scope.new(admin_user, User).resolve
        expect(policy_scope.count).to be >= 3
        expect(policy_scope).to include(admin_user, content_editor, regular_user)
      end
    end

    context 'when user is content_editor' do
      it 'returns users from same institution' do
        policy_scope = UserPolicy::Scope.new(content_editor, User).resolve
        expect(policy_scope).to include(content_editor, regular_user)
        expect(policy_scope).not_to include(other_institution_user)
      end
    end

    context 'when user is regular user' do
      it 'returns users from same institution' do
        policy_scope = UserPolicy::Scope.new(regular_user, User).resolve
        expect(policy_scope).to include(regular_user)
        expect(policy_scope.map(&:institution_id).compact.uniq).to eq([institution.id])
      end
    end
  end

  describe '#index?' do
    let(:policy) { described_class.new(user, User) }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it 'allows index' do
        expect(policy.index?).to be true
      end
    end

    context 'when user is content_editor' do
      let(:user) { create(:user, :content_editor) }

      it 'allows index' do
        expect(policy.index?).to be true
      end
    end

    context 'when user is regular user' do
      let(:user) { create(:user) }

      it 'denies index' do
        expect(policy.index?).to be false
      end
    end
  end

  describe '#update?' do
    let(:policy) { described_class.new(user, User) }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it 'allows update' do
        expect(policy.update?).to be true
      end
    end

    context 'when user is content_editor' do
      let(:user) { create(:user, :content_editor) }

      it 'allows update' do
        expect(policy.update?).to be true
      end
    end
  end
end
