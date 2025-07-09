require 'rails_helper'

RSpec.describe AppConfigPolicy do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }
  let(:app_config) { double("AppConfig") }

  subject { described_class }

  describe "permissions" do
    %i[index? edit? update?].each do |action|
      it "permits admin for #{action}" do
        expect(subject.new(admin, app_config).public_send(action)).to be true
      end

      it "forbids non-admin for #{action}" do
        expect(subject.new(user, app_config).public_send(action)).to be false
      end
    end
  end

  describe "Scope" do
    let(:scope) { AppConfig }

    it "returns AppConfig.find for admin" do
      found = double("AppConfig")
      allow(AppConfig).to receive(:find).and_return(found)
      resolved = described_class::Scope.new(admin, scope).resolve
      expect(resolved).to eq(found)
    end

    it "returns AppConfig.none for non-admin" do
      none = double("ActiveRecord::Relation")
      allow(AppConfig).to receive(:none).and_return(none)
      resolved = described_class::Scope.new(user, scope).resolve
      expect(resolved).to eq(none)
    end
  end
end
