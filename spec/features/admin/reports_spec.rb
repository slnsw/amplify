# frozen_string_literal: true

require 'rails_helper'

# /admin/reports leads to the user-contribution report, which
# Reports::UserContributions renders as a table and as CSV. Its headers and its
# data rows share one column order, which the CSV spec pins down.
RSpec.feature 'Admin reports' do
  let(:world) { build_content_world }
  let(:reports) { AdminReportsPage.new }
  let(:contributor) { create(:user, name: 'Casey Contributor') }
  let(:expected_headers) do
    ['User ID', 'Name', 'Edits', 'Lines', 'Transcripts', 'Collections', 'Institutions', 'Time Spent (s)']
  end

  describe 'as an admin' do
    before do
      world
      sign_in_as(:admin)
    end

    scenario 'renders the report index' do
      reports.visit_index
      expect(page).to have_link('Users Activity')
    end

    scenario 'lists a contributor with their lines and edits', :aggregate_failures do
      create_edits

      reports.visit_users

      expect(reports.contributor_names).to include(contributor.name)
      expect([reports.lines_for(contributor.name), reports.edits_for(contributor.name)]).to eq(%w[1 2])
    end

    scenario 'exports the documented header order' do
      expect(reports.users_csv.headers).to eq(expected_headers)
    end

    # Two edits of one line (the index is only unique per session) give the two
    # columns different values, so a swapped pair cannot pass.
    scenario 'writes each row in the header order' do
      create_edits

      row = reports.users_csv.find { |candidate| candidate['Name'] == contributor.name }

      expect(row.fields.first(4)).to eq([contributor.id.to_s, contributor.name, '2', '1'])
    end
  end

  private

  def create_edits
    line = world.transcript_lines.first
    2.times do
      create(:transcript_edit, transcript: world.transcript, transcript_line: line, user_id: contributor.id)
    end
  end
end
