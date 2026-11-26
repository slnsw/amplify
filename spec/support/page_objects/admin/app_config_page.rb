# frozen_string_literal: true

# Selectors, navigation and form filling for the site configuration form
# (app/views/admin/app_configs/edit.html.erb). It has no index: the form is
# reached from the "Site Config" entry the admin side pane renders
# (app/helpers/admin_helper.rb).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminAppConfigPage
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

  def update_main_title(value)
    page.fill_in('app_config_main_title', with: value)
    page.click_button('Save')
    page.find(FORM)
    self
  end

  private

  def page
    Capybara.current_session
  end
end
