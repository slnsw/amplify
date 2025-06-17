# frozen_string_literal: true

RSpec.describe ThemePolicy do
  subject(:create_theme) { described_class.new(user, theme) }

  let(:theme) { FactoryBot.create :theme }
  let(:policy_scope) do
    ThemePolicy::Scope.new(user, described_class).resolve
  end

  context 'when accessing controller' do
    let(:user) { FactoryBot.create :user, user_role: user_role }

    context 'with  role admin' do
      let!(:user_role) { FactoryBot.create :user_role, :admin }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }

      it 'allows admins to see all the themes' do
        create_theme
        expect(policy_scope.count).to eq 1
      end
    end

    context 'with role moderator' do
      let!(:user_role) { FactoryBot.create :user_role, :moderator }

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }

      it 'is not showing any themes' do
        create_theme
        expect(policy_scope.count).to eq 0
      end
    end
  end
end
