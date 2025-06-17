# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatsPolicy do
  let(:staff) { create(:user, :moderator) }
  let(:user)  { create(:user) }
  let(:stats) { double('Stats') }

  subject { described_class }

  describe '#index?' do
    it 'permits staff users' do
      expect(subject.new(staff, stats).index?).to be true
    end

    it 'forbids non-staff users' do
      expect(subject.new(user, stats).index?).to be false
    end
  end
end
