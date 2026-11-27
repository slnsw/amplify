# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Sign out', :js do
  let!(:world) { build_content_world }
  let(:editor) { TranscriptEditorPage.new }
  let!(:user) { sign_in_as(:user) }

  before do
    # The account widget is hidden below the tablet breakpoint
    # (components/menu_dropdown.scss); the driver opens a desktop-sized window.
    editor.visit_transcript(world.transcript)
  end

  scenario 'shows the visitor their own account state on the editor' do
    expect(account_widget_text).to include(user.name)
  end

  scenario 'returns the visitor to a public page and drops the user-scoped editor state',
           :aggregate_failures do
    sign_out
    expect(page).to have_current_path('/')
    editor.visit_transcript(world.transcript)
    expect(account_widget_text).to eq('Track my progress')
    expect(page).to have_no_link('Sign out', visible: :all)
  end

  private

  # The menu only opens on click (app/assets/javascripts/fixed_header.js).
  def sign_out
    page.find('#select_title').click
    page.click_link('Sign out')
  end

  # `text(:all)` because the widget uppercases the signed-in user's name
  # (components/menu_dropdown.scss), and because the signed-out label is a link.
  def account_widget_text
    page.find('#select_title').text(:all).squish
  end
end
