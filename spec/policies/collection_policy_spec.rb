# frozen_string_literal: true

RSpec.describe CollectionPolicy do
  subject { described_class.new(user, collection)  }

  let(:collection) { FactoryBot.create :collection }

  context 'when accessing controller' do
    let(:user) { FactoryBot.create :user, user_role: user_role }

    context 'with  role admin' do
      let!(:user_role) { FactoryBot.create :user_role, :admin }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'with role content editor' do
      let!(:user_role) { FactoryBot.create :user_role, :content_editor }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end

    context 'with role moderator' do
      let!(:user_role) { FactoryBot.create :user_role, :moderator }

      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end
end
