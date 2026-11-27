# frozen_string_literal: true

require 'rails_helper'

# /admin renders StatsService#all_stats and /admin/stats/:id/institution the
# per-institution breakdown the institution select loads
# (app/controllers/admin/stats_controller.rb). The counts are transcript edits,
# which is what the service tallies.
RSpec.feature 'Admin statistics' do
  let(:world) { build_content_world }
  let(:stats) { AdminStatsPage.new }

  describe 'as an admin' do
    scenario 'counts the edits the site has received', :aggregate_failures do
      world
      sign_in_as(:admin)
      expect(stats.visit_dashboard.item_edit_count).to eq(0)

      create(:transcript_edit, transcript: world.transcript, transcript_line: world.transcript_lines.first)

      expect(stats.visit_dashboard.item_edit_count).to eq(1)
    end
  end

  describe 'the per-institution breakdown as an admin', :js do
    before do
      world
      sign_in_as(:admin)
      stats.visit_dashboard
    end

    # An edit in a second institution is what makes the filter visible: with edits
    # only in the chosen institution its count equals the site-wide total, so a
    # service that ignored the institution entirely would look correct.
    # rubocop:disable RSpec/ExampleLength
    scenario 'counts only the edits of the chosen institution', :aggregate_failures do
      expect(stats.choose_institution(world.institution.name).institution_edit_count).to eq(0)

      create(:transcript_edit, transcript: world.transcript, transcript_line: world.transcript_lines.first)
      elsewhere = build_content_world
      create(:transcript_edit, transcript: elsewhere.transcript,
                               transcript_line: elsewhere.transcript_lines.first)

      expect(stats.visit_dashboard.item_edit_count).to eq(2)
      expect(stats.choose_institution(world.institution.name).institution_edit_count).to eq(1)
    end

    # Selecting a second institution without reloading is what shows the figures
    # belong to the new selection: the previous set is already on the page, so a
    # read that raced the response would answer with the first institution's counts.
    scenario 'switches the figures when another institution is chosen', :aggregate_failures do
      second = build_content_world
      create(:transcript_edit, transcript: world.transcript, transcript_line: world.transcript_lines.first)
      2.times do
        create(:transcript_edit, transcript: second.transcript, transcript_line: second.transcript_lines.first)
      end

      stats.visit_dashboard
      expect(stats.choose_institution(world.institution.name).institution_edit_count).to eq(1)
      expect(stats.choose_institution(second.institution.name).institution_edit_count).to eq(2)
      expect(stats.choose_institution(world.institution.name).institution_edit_count).to eq(1)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
