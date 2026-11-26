# frozen_string_literal: true

# Selectors and form filling for the signed-in staff member's own profile
# (app/views/admin/profiles/). The form has no name field: it switches the
# `transcribing_role` of the user's role record, which Admin::ProfilesController
# writes for admins only.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminProfilePage
  PATH = '/admin/profiles'
  REGISTERED_USER = 'user_role_transcribing_role_registered_user'
  ADMIN_USER = 'user_role_transcribing_role_admin'
  SAVE = 'Save Profile'

  def visit_profile
    page.visit(PATH)
    self
  end

  def choose_registered_user_role
    page.choose(REGISTERED_USER)
    page.click_button(SAVE)
    self
  end

  def transcribing_role
    [['admin', ADMIN_USER], ['registered_user', REGISTERED_USER]]
      .find { |_role, id| page.find("##{id}").checked? }
      &.first
  end

  private

  def page
    Capybara.current_session
  end
end
