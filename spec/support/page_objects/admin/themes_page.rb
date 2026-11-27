# frozen_string_literal: true

# Selectors, navigation and form filling for admin theme management
# (app/views/admin/themes/). A theme is only its name, so the form is one field.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminThemesPage
  include ListTexts

  INDEX_PATH = '/admin/themes'
  ROWS = 'table tbody tr'
  # The list heading every save redirects back to.
  INDEX_HEADING = 'h1'
  INDEX_TITLE = 'Themes'
  NAME_CELL = 'td:nth-child(1)'
  EDIT_LINK = 'a .fa-edit'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def names = texts_for("#{ROWS} #{NAME_CELL}")

  def open_new
    page.click_link('New Theme')
    self
  end

  def create(name)
    visit_index.open_new
    page.fill_in('theme_name', with: name)
    page.click_button('Save')
    wait_for_index
    self
  end

  def edit(name)
    page.find(ROWS, text: name).find(EDIT_LINK).click
    self
  end

  def rename(from:, to:)
    edit(from)
    page.fill_in('theme_name', with: to)
    page.click_button('Save')
    wait_for_index
    self
  end

  private

  # Every save redirects back to the list, so waiting for its heading keeps the
  # next navigation from racing the post/redirect round trip.
  def wait_for_index = page.find(INDEX_HEADING, text: INDEX_TITLE)

  def page
    Capybara.current_session
  end
end
