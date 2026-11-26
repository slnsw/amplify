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
        assert_totals(items: 0, duration: '00h 00m 00s')
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
        assert_totals(items: 2, duration: '01h 06m 28s')
        expect(page).to have_text('Completed')
        expect(page).to have_text('0.00 %')
        expect(page).to have_text('Not yet started')
      end

      it 'shows the totals of the selected institution' do
        expect_settled_totals(items: 2, duration: '01h 06m 28s')

        select institution.name, from: 'institution_id'

        expect_settled_totals(items: 1, duration: '00h 33m 20s')
      end

      it 'shows the totals of the other institution' do
        expect_settled_totals(items: 2, duration: '01h 06m 28s')

        select another_institution.name, from: 'institution_id'

        expect_settled_totals(items: 1, duration: '00h 33m 08s')
      end

      # Switching rather than selecting once: the item count stays at 1, so only
      # the duration moving from one institution's total to the other's shows the
      # filter followed the second choice instead of staying on the first.
      it 'follows the filter when a different institution is chosen' do
        expect_settled_totals(items: 2, duration: '01h 06m 28s')

        select institution.name, from: 'institution_id'
        expect_settled_totals(items: 1, duration: '00h 33m 20s')

        select another_institution.name, from: 'institution_id'
        expect_settled_totals(items: 1, duration: '00h 33m 08s')
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

      it 'narrows the totals to the selected start date' do
        expect_settled_totals(items: 2, duration: '00h 50m 00s')

        set_date_field('start_date', Date.current - 1.month)

        expect_settled_totals(items: 1, duration: '00h 16m 40s')
      end

      # Two transitions rather than one: the totals have to move to one item and
      # back to two, so a start date that never reached the server cannot pass.
      it 'keeps the items an earlier start date restores' do
        expect_settled_totals(items: 2, duration: '00h 50m 00s')

        set_date_field('start_date', Date.current - 1.month)
        expect_settled_totals(items: 1, duration: '00h 16m 40s')

        set_date_field('start_date', Date.new(2021, 11, 26))
        expect_settled_totals(items: 2, duration: '00h 50m 00s')
      end
    end
  end

  private

  # Anchor and scope the totals: an unanchored match would accept "1" inside
  # "10", and an unscoped one could be satisfied by any text on the page.
  def assert_totals(items:, duration:)
    expect(page).to have_css('#summary-stats h3', text: /\ATotal number of items: #{items}\z/)
    expect(page).to have_css('#summary-stats p', text: /\ATotal duration of items: #{duration}\z/)
  end

  # `loadSummary` replaces #summary-stats with whichever response arrives last
  # and never compares requests, so a filter response can land after the totals
  # were asserted and overwrite them — an example that asserts and stops passes
  # on a page that is not showing what it claims. Drain the requests, then
  # assert again.
  def expect_settled_totals(items:, duration:)
    assert_totals(items: items, duration: duration)
    wait_for_ajax_settle
    assert_totals(items: items, duration: duration)
  end

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
