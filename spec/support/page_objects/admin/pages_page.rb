# frozen_string_literal: true

require_relative 'rich_text'

# Selectors, navigation and form filling for admin page management
# (app/views/admin/pages/): the page list and the new/edit form with its
# Summernote body.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminPagesPage
  include AdminRichText

  INDEX_PATH = '/admin/pages'
  ROWS = 'table tbody tr'
  # The list heading every save redirects back to.
  INDEX_HEADING = 'h1'
  INDEX_TITLE = 'Pages'
  TYPE_CELL = 'td:nth-child(1)'
  EDIT_LINK = 'a .fa-edit'
  DELETE_BUTTON = 'button .fa-trash'
  # Summernote keeps the submitted text in the textarea it hides.
  CONTENT_FIELD = '#page_content'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def page_types = page.all("#{ROWS} #{TYPE_CELL}").map(&:text)

  def open_new
    page.click_link('New Page')
    self
  end

  def create(page_type:, body:)
    visit_index.open_new
    page.fill_in('page_page_type', with: page_type)
    type_into_editor(body)
    page.click_button('Save')
    wait_for_index
    self
  end

  def edit(page_type)
    row(page_type).find(EDIT_LINK).click
    self
  end

  def content = page.find(CONTENT_FIELD, visible: :all).value

  def delete(page_type)
    page.accept_confirm { row(page_type).find(DELETE_BUTTON).click }
    self
  end

  private

  # Every save redirects back to the list, so waiting for its heading keeps the
  # next navigation from racing the post/redirect round trip.
  def wait_for_index = page.find(INDEX_HEADING, text: INDEX_TITLE)

  def row(page_type) = page.find(ROWS, text: page_type)

  def page
    Capybara.current_session
  end
end
