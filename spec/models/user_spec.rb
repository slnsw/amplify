# frozen_string_literal: true

RSpec.describe User, type: :model do
  # associations
  it { is_expected.to belong_to(:institution) }

  # scopes
  context "with scopes" do
    let(:admin_role) { create :user_role, :admin, id: 5 }
    let(:registred_user_role) { create :user_role, id: 2 }

    let!(:admin_user) { create :user, user_role: admin_role }
    let!(:registred_user) { create :user, user_role: registred_user_role }

    context "with .only staff users" do
      it "shows the admin" do
        expect(described_class.only_staff_users).to eq([admin_user])
        expect(described_class.only_staff_users).not_to eq([registred_user])
      end
    end

    context "with .only public users" do
      it "shows the public user" do
        expect(described_class.only_public_users).to eq([registred_user])
        expect(described_class.only_public_users).not_to eq([admin_user])
      end
    end
  end

  # class methods
  context "class methods" do
    let(:registred_user_role) { create :user_role, id: 2 }

    let(:institution_1) { create :institution, name: "Australian War Memorial" }
    let(:institution_2) { create :institution, name: "State Library of Queensland" }
    let(:institution_3) { create :institution, name: "Wollongong City Libraries" }

    let!(:user_1) { create :user, user_role: registred_user_role }
    let!(:user_2) { create :user, user_role: registred_user_role, institution: institution_1 }
    let!(:user_3) { create :user, user_role: registred_user_role, institution: institution_2 }
    let!(:user_4) { create :user, user_role: registred_user_role, institution: institution_3 }

    describe "#orderByInstitution" do
      it "arrange users on ascending order based on institution name" do
        expect(User.orderByInstitution).to eq [user_1, user_2, user_3, user_4]
        expect(User.orderByInstitution.first.institution).to eq nil
        expect(User.orderByInstitution.last.institution.name).to eq institution_3.name
      end
    end
  end
end
