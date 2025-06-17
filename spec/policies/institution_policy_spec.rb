# frozen_string_literal: true

RSpec.describe InstitutionPolicy do
  let!(:institution) { FactoryBot.create :institution }
  let!(:institution2) { FactoryBot.create :institution }

  context 'when accessing scope' do
    let(:user) do
      FactoryBot.create :user, user_role: user_role, institution: institution
    end
    let(:policy_scope) do
      InstitutionPolicy::Scope.new(user, Institution).resolve
    end

    context 'with admin role' do
      let!(:user_role) { FactoryBot.create :user_role, :admin }

      it 'allows admins to see all the institutions' do
        expect(policy_scope.count).to eq 2
      end
    end

    context 'with content_editor role' do
      let!(:user_role) { FactoryBot.create :user_role, :content_editor }

      it 'allows content_editors to see only their institutions' do
        expect(policy_scope.count).to eq 1
      end
    end

    context 'with moderator role' do
      let!(:user_role) { FactoryBot.create :user_role, :moderator }

      it 'does not allows moderators to see all the institutions' do
        expect(policy_scope.count).to eq(0)
      end
    end
  end
end
