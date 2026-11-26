# frozen_string_literal: true

require_relative 'rich_text'

# Selectors, navigation and form filling for CMS collection management
# (app/views/admin/cms/show.html.erb, app/views/admin/cms/collections/).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminCmsCollectionsPage
  include ListTexts

  include AdminRichText

  INDEX_PATH = '/admin/cms'
  ROWS = 'table tbody tr'
  # The list renders publish, uid, title and item count, then the icon columns.
  TITLE_CELL = 'td:nth-child(3)'
  # Every row action is a `button_to`, so the icon sits inside a submit button.
  EDIT_BUTTON = 'button .fa-edit'
  # The form shows a thumbnail of the stored image when there is one.
  IMAGE_PREVIEW = '.form-control.image img'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def titles = texts_for("#{ROWS} #{TITLE_CELL}")

  def open_new
    page.click_button('Create a new collection')
    self
  end

  # `image` is a path on disk, as `attach_file` requires.
  def create(uid:, title:, description:, institution:, image: nil)
    open_new
    page.fill_in('collection_uid', with: uid)
    page.fill_in('collection_title', with: title)
    type_into_editor(description)
    page.select(institution, from: 'collection_institution_id')
    page.attach_file('collection_image', image) if image
    page.click_button('Save')
    wait_for_index
    self
  end

  def edit(title)
    page.find(ROWS, text: title).find(EDIT_BUTTON).click
    self
  end

  def retitle(to:)
    page.fill_in('collection_title', with: to)
    page.click_button('Save')
    wait_for_index
    self
  end

  def image_preview? = page.has_css?(IMAGE_PREVIEW)

  private

  # Saving returns to the index; waiting for its "Create a new collection" button
  # keeps the next read from racing the redirect and seeing the form's empty page.
  def wait_for_index = page.find_button('Create a new collection')

  def page
    Capybara.current_session
  end
end
