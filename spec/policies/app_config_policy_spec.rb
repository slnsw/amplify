# frozen_string_literal: true

RSpec.describe AppConfigPolicy do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:app_config) { double('app_config') }

  describe '#index?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, app_config)
      expect(policy.index?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, app_config)
      expect(policy.index?).to be false
    end
  end

  describe '#edit?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, app_config)
      expect(policy.edit?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, app_config)
      expect(policy.edit?).to be false
    end
  end

  describe '#update?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, app_config)
      expect(policy.update?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, app_config)
      expect(policy.update?).to be false
    end
  end

  describe 'Scope' do
    before do
      allow(AppConfig).to receive(:find).and_return(app_config)
      allow(AppConfig).to receive(:none).and_return([])
    end

    context 'when user is admin' do
      it 'returns AppConfig' do
        policy_scope = AppConfigPolicy::Scope.new(admin_user, AppConfig).resolve
        expect(policy_scope).to eq(app_config)
      end
    end

    context 'when user is not admin' do
      it 'returns none' do
        policy_scope = AppConfigPolicy::Scope.new(regular_user, AppConfig).resolve
        expect(policy_scope).to eq([])
      end
    end
  end
end
