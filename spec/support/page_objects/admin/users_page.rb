# frozen_string_literal: true

require_relative '../../features/waits'

# Selectors, navigation and interactions for the admin user list
# (app/views/admin/users/). The role and institution columns are selects whose
# change event PUTs the user record (app/assets/javascripts/users.js), and the
# list splits public and staff users into two Bootstrap tabs.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host: the user it is
# handed only has to expose `id`.
class AdminUsersPage
  include Waits

  INDEX_PATH = '/admin/users'
  ROLE_SELECT = 'select.user_role'
  REGISTERED_TAB = 'Registered Users'
  ADMINISTRATIVE_TAB = 'Administrative Users'
  # `User#only_public_users` / `only_staff_users` split the list by the role
  # row's id, not by its hiearchy, so which tab holds a user depends on the data.
  # The value mirrors UserRole::MIN_STAFF_LEVEL, which the page object does not
  # load Rails to read.
  STAFF_ROLE_LEVEL = 3

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def open_pane_for(user)
    page.click_link(user.user_role_id < STAFF_ROLE_LEVEL ? REGISTERED_TAB : ADMINISTRATIVE_TAB)
    self
  end

  # `role` is the role row whose description the select renders, e.g.
  # `UserRole.find_by(name: 'admin')`.
  def change_role(user, role:)
    page.find("#{ROLE_SELECT}[data-id='#{user.id}']").select(role.description)
    # The PUT answers 204 and changes nothing on the page, so the only way to
    # know the record was written is for its request to have finished.
    wait_for_ajax_settle
    self
  end

  private

  def page
    Capybara.current_session
  end
end
