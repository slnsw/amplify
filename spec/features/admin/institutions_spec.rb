require "rails_helper"

RSpec.describe "Institution Page" do
  let(:admin) { create(:user, :admin) }
  let!(:institution1) { create(:institution, name: "First institution") }
  let!(:institution2) { create(:institution, name: "Second institution") }

  describe "the Institution page as an admin", js: true do
    context "with collections and institutions" do
      before do
        sign_in admin
        visit admin_institutions_path
      end

      it "shows all institutions on the page" do
        expect(page).to have_text("First institution")
        expect(page).to have_text("Second institution")
      end
    end

    context "when creating a new institution" do
      before do
        sign_in admin
        visit new_admin_institution_path
      end

      it "shows the institution fields" do
        expect(page).to have_text("New Institution")
        expect(page).to have_text("Custom footer links")
      end
    end

    context "when editing an institution" do
      before do
        sign_in admin
        visit edit_admin_institution_path(institution1)
      end

      it "shows the institution fields" do
        expect(page).to have_text("Editing Institution")
        expect(page).to have_text("Custom footer links")
      end

      it "allows an admin to save institution details" do
        fill_in("UID", with: "firstinstitution")
        within(:css, "#institution-link-0") do
          fill_in("institution[institution_links][][title]", with: "My Link")
          fill_in("institution[institution_links][][url]", with: "http://www.mylink.com")
        end
        click_button("Save")
        expect(page).to have_current_path(admin_institutions_path, wait: 5)
        institution1.reload
        expect(institution1.slug).to eq("firstinstitution")
        expect(institution1.institution_links.first.title).to eq("My Link")
      end
    end
  end
end
