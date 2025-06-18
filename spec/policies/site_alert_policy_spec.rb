require "rails_helper"

RSpec.describe SiteAlertPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }
  let!(:site_alert) do
    SiteAlert.create!(
      machine_name: "alert_1",
      level: "status",
      message: "This is a test alert message.",
      user_id: admin.id,
      published: true,
      admin_access: true,
      scheduled: false,
      publish_at: Time.current,
      unpublish_at: Time.current + 1.day,
    )
  end

  describe "permissions" do
    %i[index? update?].each do |action|
      it "permits admin for #{action}" do
        expect(subject.new(admin, site_alert).public_send(action)).to be true
      end

      it "forbids non-admin for #{action}" do
        expect(subject.new(user, site_alert).public_send(action)).to be false
      end
    end
  end

  describe "Scope" do
    let(:scope) { SiteAlert }

    it "returns all site alerts for admin" do
      resolved = described_class::Scope.new(admin, scope).resolve
      expect(resolved).to match_array(SiteAlert.all)
    end

    it "returns nil for non-admin" do
      resolved = described_class::Scope.new(user, scope).resolve
      expect(resolved).to be_nil
    end
  end
end
