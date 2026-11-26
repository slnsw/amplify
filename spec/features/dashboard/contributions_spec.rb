# frozen_string_literal: true

require 'rails_helper'

# /dashboard lists the signed-in user's transcript edits
# (DashboardController#index -> TranscriptEdit.getByUser).
RSpec.feature 'Dashboard contributions' do
  let(:world) { build_content_world }

  describe 'with an edit' do
    let(:user) { sign_in_as(:user) }
    let(:dashboard) { DashboardPage.new }

    before do
      create_edit(world, user, text: 'The dashboard shows this edit.')
      dashboard.visit_path
    end

    scenario 'lists the edited transcript with its title and the contribution summary', :aggregate_failures do
      expect(dashboard.transcript_titles).to eq([world.transcript.title])
      expect(dashboard.summary).to include('You have edited 1 lines in 1 transcripts')
    end

    scenario 'lists the edit text under the transcript' do
      expect(dashboard.edits).to eq(['The dashboard shows this edit.'])
    end
  end

  scenario "lists only the signed-in user's own edits" do
    user = sign_in_as(:user)
    other_user = create(:user, user_role: user.user_role)
    create_edit(world, user, text: 'An edit of mine.')
    create_edit(world, other_user, text: 'An edit of someone else.')

    expect(DashboardPage.new.visit_path.edits).to eq(['An edit of mine.'])
  end

  scenario 'shows the empty state for a user without edits', :aggregate_failures do
    sign_in_as(:user)
    dashboard = DashboardPage.new.visit_path
    expect(dashboard.empty_state).to eq("You don't have any transcript edits yet!")
    expect(dashboard.transcript_titles).to be_empty
  end

  scenario 'sends an anonymous visitor to the sign-in page', :aggregate_failures do
    visit '/dashboard'
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_button(SignInPage::SUBMIT_BUTTON)
  end

  private

  def create_edit(world, user, text:)
    create(:transcript_edit, transcript: world.transcript, transcript_line: world.transcript_lines.first,
                             user_id: user.id, text: text)
  end
end
