# frozen_string_literal: true

require 'rails_helper'

# Flag moderation runs through two surfaces: the unresolved-flag table the admin
# dashboard renders (app/views/admin/stats/_flags_table.html.erb, fed by
# Flag.pending_flags) and the editor's resolve control, which posts
# /transcript_lines/:id/resolve. The routes the plan names for this area,
# /admin/flags and /moderator, both point at an Admin::FlagsController that does
# not exist and answer 500, so the dashboard is the surface under test.
RSpec.feature 'Flag moderation' do
  let(:world) { build_content_world(line_overrides: { 0 => { status: 'completed', flagged: true } }) }
  let(:flags) { AdminFlagsPage.new }

  describe 'the unresolved flags as an admin' do
    scenario 'are listed on the dashboard', :aggregate_failures do
      world
      sign_in_as(:admin)

      flags.visit_dashboard

      expect(flags.pending_flags.join).to include(world.transcript.title)
      expect(flags.flag_types).to include(world.flag_types.first.label)
    end
  end

  describe 'resolving a flag as an admin', :js do
    # The line controls are revealed once the line is selected and are hidden
    # below the desktop breakpoint; the driver opens a desktop-sized window.
    before do
      world
      sign_in_as(:admin)
    end

    scenario 'removes it from the dashboard queue', :aggregate_failures do
      flags.visit_dashboard
      expect(flags.pending_flags.join).to include(world.transcript.title)

      TranscriptEditorPage.new.visit_transcript(world.transcript).resolve_line(0).reload

      flags.visit_dashboard
      expect(flags.pending_flags).to be_empty
    end
  end
end
