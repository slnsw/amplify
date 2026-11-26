# frozen_string_literal: true

require 'rails_helper'

# /admin/summary renders StatsService#completion_stats. The page loads the totals
# itself over /admin/summary/details when it boots and again whenever a filter
# changes (app/assets/javascripts/summary.js), so every assertion waits for the
# injected `#summary-stats` content.
RSpec.feature 'Summary Page' do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin) { create(:user, :admin) }

  describe 'the Summary page as an admin', :js do
    context 'without collections and institutions' do
      before do
        sign_in admin
        visit admin_summary_index_path
      end

      it 'shows the summary page', :aggregate_failures do
        expect(page).to have_text('Collection transcription progress')
        expect(page).to have_text('Start date')
        expect(page).to have_text('End date')
        expect(page).to have_current_path(admin_summary_index_path)
      end

      it 'shows an empty stats page', :aggregate_failures do
        expect(page).to have_text('Total number of items: 0')
        expect(page).to have_text('Total duration of items: 00h 00m 00s')
        expect(page).to have_text('0.00 %', count: 4)
        expect(page).to have_text('Disk usage')
        expect(page).to have_text('0 Bytes', count: 4)
      end
    end

    context 'with two institutions holding one item each' do
      let!(:institution) { create(:institution) }
      let!(:another_institution) { create(:institution) }

      before do
        create(:transcript, collection: create(:collection, institution: institution), duration: 2000)
        create(:transcript, collection: create(:collection, institution: another_institution), duration: 1988)

        sign_in admin
        visit admin_summary_index_path
      end

      it 'shows the site-wide totals', :aggregate_failures do
        expect(page).to have_text('Total number of items: 2')
        expect(page).to have_text('Total duration of items: 01h 06m 28s')
        expect(page).to have_text('Completed')
        expect(page).to have_text('0.00 %')
        expect(page).to have_text('Not yet started')
      end

      it 'keeps every item when the start date precedes them', :aggregate_failures do
        fill_in 'start_date', with: Date.new(2021, 11, 26)

        expect(page).to have_text('Total number of items: 2')
        expect(page).to have_text('Total duration of items: 01h 06m 28s')
      end

      it 'shows the totals of the selected institution', :aggregate_failures do
        select institution.name, from: 'institution_id'

        expect(page).to have_text('Total number of items: 1')
        expect(page).to have_text('Total duration of items: 00h 33m 20s')
        expect(page).to have_text('Not yet started')
      end

      it 'shows the totals of the other institution', :aggregate_failures do
        select another_institution.name, from: 'institution_id'

        expect(page).to have_text('Total number of items: 1')
        expect(page).to have_text('Total duration of items: 00h 33m 08s')
      end
    end

    # StatsService filters on `transcripts.updated_at`, so the items have to be
    # written in different months for a start date to exclude one of them.
    context 'with items updated in different months' do
      before do
        collection = create(:collection, institution: create(:institution))
        travel_to(2.months.ago) { create(:transcript, collection: collection, duration: 2000) }
        create(:transcript, collection: collection, duration: 1000)

        sign_in admin
        visit admin_summary_index_path
      end

      # Asserted against #summary-stats and anchored, so a value cannot be satisfied by
      # a longer number or by text elsewhere on the page. The boot request is drained
      # before the filter is applied, and the filtered request is drained after the
      # assertions, which closes the ordering question at both ends: `loadSummary`
      # replaces #summary-stats with whichever response arrives last and never
      # compares requests, so a request still in flight could otherwise overwrite
      # the totals the assertions had just seen.
      # rubocop:disable RSpec/ExampleLength
      it 'narrows the totals to the selected start date', :aggregate_failures do
        expect(page).to have_css('#summary-stats h3', text: /\ATotal number of items: 2\z/)
        wait_for_ajax_settle

        set_date_field('start_date', Date.current - 1.month)

        expect(page).to have_css('#summary-stats h3', text: /\ATotal number of items: 1\z/)
        expect(page).to have_css('#summary-stats p', text: /\ATotal duration of items: 00h 16m 40s\z/)

        wait_for_ajax_settle
        expect(page).to have_css('#summary-stats h3', text: /\ATotal number of items: 1\z/)
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  private

  # `fill_in` types a date input character by character, and summary.js starts a
  # request on every change event. Those responses all replace `#summary-stats`
  # without an ordering check, so an earlier one can land last and overwrite the
  # final totals. Set the value once and fire a single change instead.
  def set_date_field(id, value)
    page.execute_script(<<~JS, id, value.to_s)
      var field = document.getElementById(arguments[0]);
      field.value = arguments[1];
      field.dispatchEvent(new Event('change', { bubbles: true }));
    JS
  end
end
