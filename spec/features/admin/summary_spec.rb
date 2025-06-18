require "rails_helper"

RSpec.describe "Summary Page" do
  let(:admin) { create(:user, :admin) }

  describe "the Summary page as an admin", js: true do
    context "without collections and institutions" do
      before do
        sign_in admin
        visit admin_summary_index_path
      end

      it "shows the summary page" do
        expect(page).to have_text("Collection transcription progress")
        expect(page).to have_text("Start date")
        expect(page).to have_text("End date")
        expect(page).to have_current_path(admin_summary_index_path)
      end

      it "shows an empty stats page" do
        expect(page).to have_text("Total number of items: 0")
        expect(page).to have_text("Total duration of items: 00h 00m 00s")
        expect(page).to have_text("0.00 %", count: 4)

        expect(page).to have_text("Disk usage")
        expect(page).to have_text("0 Bytes", count: 4)
      end
    end

    context "with collections and institutions" do
      let!(:institution) { create(:institution) }
      let!(:collection) { create(:collection, institution: institution) }
      let!(:transcript) { create(:transcript, collection: collection, duration: 2000, created_at: Date.new(2021, 11, 28)) }

      let!(:another_institution) { create(:institution) }
      let!(:another_collection) { create(:collection, institution: another_institution) }
      let!(:another_transcript) { create(:transcript, collection: another_collection, duration: 1988, created_at: Date.new(2021, 11, 24)) }

      before do
        sign_in admin
        visit admin_summary_index_path
      end

      context "viewing all stats" do
        it "shows all stats on the page" do
          expect(page).to have_text("Total number of items: 2")
          expect(page).to have_text("Total duration of items: 01h 06m 28s")
          expect(page).to have_text("Completed")
          expect(page).to have_text("0.00 %")
          expect(page).to have_text("Not yet started")
        end
      end

      xcontext "when selecting a start_date" do
        xit "filters the stats by date" do
          fill_in "start_date", with: "26112021"
          expect(page).to have_text("Total number of items: 2")
          expect(page).to have_text("Total duration of items: 01h 06m 28s")
          expect(page).to have_text("Completed")
          expect(page).to have_text("0.00 %")
        end
      end

      xcontext "sellecting an institution from the dropdown" do
        xit "shows the stats of the first institution" do
          select institution.name, from: "institution_id"
          expect(page).to have_text("Total number of items: 1")
          expect(page).to have_text("Total duration of items: 00h 33m 20s")
          expect(page).to have_text("Completed")
          expect(page).to have_text("0.00 %")
          expect(page).to have_text("Not yet started")
        end

        xit "shows the stats of the second institution" do
          select another_institution.name, from: "institution_id"
          expect(page).to have_text("Total number of items: 1")
          expect(page).to have_text("Total duration of items: 00h 33m 08s")
        end
      end
    end
  end
end

# Note: Revisit these tests as some specs on these tests are flaky.
