# frozen_string_literal: true

require 'rails_helper'

# /admin/profiles lets a staff member change the role they transcribe as
# (app/controllers/admin/profiles_controller.rb). There is no name field - the
# form switches `transcribing_role` on the user's role record - so that is the
# profile mutation this spec proves.
RSpec.feature 'Admin profile' do
  let(:profile) { AdminProfilePage.new }

  describe 'as an admin' do
    before { sign_in_as(:admin) }

    scenario 'renders the profile form', :aggregate_failures do
      profile.visit_profile

      expect(page).to have_text('Edit My Profile')
      expect(page).to have_field(AdminProfilePage::ADMIN_USER)
    end

    # `transcribing_role` defaults to `registered_user`, so choosing that one
    # saved the value the record already held and the assertion after the reload
    # passed whether or not the write happened. Switch to `admin`, which only
    # appears in the record if the update ran, and read the starting value first.
    scenario 'persists the transcribing role across a reload', :aggregate_failures do
      expect(profile.visit_profile.transcribing_role).to eq('registered_user')

      profile.choose_admin_role

      expect(page).to have_text("Admin's transcribing role has been updated to admin.")
      page.refresh
      expect(profile.transcribing_role).to eq('admin')
    end
  end
end
