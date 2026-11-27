# frozen_string_literal: true

require_relative '../document_waits'

# Selectors, navigation and form filling for the site configuration form
# (app/views/admin/app_configs/edit.html.erb). It has no index: the form is
# reached from the "Site Config" entry the admin side pane renders
# (app/helpers/admin_helper.rb).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminAppConfigPage
  include DocumentWaits

  # Any admin page renders the side pane; the dashboard is the cheapest.
  ADMIN_PATH = '/admin'
  SIDE_PANE_LINK = 'Site Config'
  # The form is a singleton record, so its id carries the record id.
  FORM = 'form[action*="/admin/app_configs/"]'

  def visit_form
    page.visit(ADMIN_PATH)
    page.click_link(SIDE_PANE_LINK)
    self
  end

  def main_title = page.find('#app_config_main_title', visible: :all).value

  # The form is on the page before and after the save, so waiting for it says
  # nothing: the response redirects to the same route and the input already holds
  # the typed value. Waiting for a new document is what puts the read after the
  # write.
  def update_main_title(value)
    page.fill_in('app_config_main_title', with: value)
    wait_for_new_document { page.click_button('Save') }
    self
  end

  private

  def page
    Capybara.current_session
  end
end
