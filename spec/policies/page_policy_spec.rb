# frozen_string_literal: true

RSpec.describe PagePolicy do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:page) { create(:page) }

  describe '#index?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, page)
      expect(policy.index?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, page)
      expect(policy.index?).to be false
    end
  end

  describe '#update?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, page)
      expect(policy.update?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, page)
      expect(policy.update?).to be false
    end
  end

  describe '#show?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, page)
      expect(policy.show?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, page)
      expect(policy.show?).to be false
    end
  end

  describe '#destroy?' do
    it 'allows admin users' do
      policy = described_class.new(admin_user, page)
      expect(policy.destroy?).to be true
    end

    it 'denies non-admin users' do
      policy = described_class.new(regular_user, page)
      expect(policy.destroy?).to be false
    end
  end

  describe 'Scope' do
    let!(:page1) { create(:page, page_type: 'test_page_1') }
    let!(:page2) { create(:page, page_type: 'test_page_2') }

    context 'when user is admin' do
      it 'returns all pages' do
        policy_scope = PagePolicy::Scope.new(admin_user, Page).resolve
        expect(policy_scope).to include(page1, page2)
      end
    end

    context 'when user is not admin' do
      it 'returns nil' do
        policy_scope = PagePolicy::Scope.new(regular_user, Page).resolve
        expect(policy_scope).to be_nil
      end
    end
  end
end
