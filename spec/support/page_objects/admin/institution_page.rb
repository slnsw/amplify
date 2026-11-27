# frozen_string_literal: true

# Selectors, navigation and form filling for the admin institution list
# (app/views/admin/institutions/), its form, and the transcription conventions
# nested under one institution (app/views/admin/transcription_conventions/).
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host: the
# institution it is handed only has to expose `slug`.
class AdminInstitutionPage
  include ListTexts

  INDEX_PATH = '/admin/institutions'
  ROWS = 'table tbody tr'
  # The list renders name, slug and url, then the icon columns.
  NAME_CELL = 'td:nth-child(1)'
  URL_CELL = 'td:nth-child(3)'
  # `fa_icon` renders inside the anchor, so clicking the icon follows the link.
  EDIT_LINK = 'a .fa-edit'
  # The footer-link rows are keyed by position; the first is index 0.
  FIRST_FOOTER_LINK = '#institution-link-0'
  FOOTER_LINK_TITLES = '#institution-links input[name$="[title]"]'
  # The list's only "New ..." link; the form itself renders "New record".
  CONVENTIONS_LINK = 'New Transcription Convention'
  CONVENTION_KEY_CELL = 'td:nth-child(1)'
  CONVENTION_TEXT_CELL = 'td:nth-child(2)'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def names = texts_for("#{ROWS} #{NAME_CELL}")

  def url_of(name) = row(name).find(URL_CELL).text

  # Opens the edit form from the list row, the way an admin reaches it.
  def edit(name)
    row(name).find(EDIT_LINK).click
    self
  end

  # `fields` maps a form field id, e.g. `institution_url`, to its new value.
  def fill(fields)
    fields.each { |field_id, value| page.fill_in(field_id, with: value) }
    self
  end

  def fill_first_footer_link(title:, url:)
    page.within(FIRST_FOOTER_LINK) do
      page.fill_in('institution[institution_links][][title]', with: title)
      page.fill_in('institution[institution_links][][url]', with: url)
    end
    self
  end

  def footer_link_titles = page.all(FOOTER_LINK_TITLES).map(&:value)

  # Saving redirects to the list, which is the only page that renders this link.
  # Waiting for it keeps the next read from running while the browser is still
  # replacing the document, which is what surfaced as chromedriver answering
  # "Node with given id does not belong to the document".
  def save
    page.click_button('Save')
    page.find_link('New Institution')
    self
  end

  def visit_conventions(institution)
    page.visit("#{INDEX_PATH}/#{institution.slug}/transcription_conventions")
    self
  end

  def convention_keys = texts_for("#{ROWS} #{CONVENTION_KEY_CELL}")

  def convention_text_for(key) = row(key).find(CONVENTION_TEXT_CELL).text

  def create_convention(key:, text:, example:)
    page.click_link(CONVENTIONS_LINK)
    page.fill_in('Convention key', with: key)
    page.fill_in('Convention text', with: text)
    page.fill_in('Example', with: example)
    page.click_button('Save')
    wait_for_conventions
    self
  end

  def update_convention(key, text:)
    row(key).find(EDIT_LINK).click
    page.fill_in('Convention text', with: text)
    page.click_button('Save')
    wait_for_conventions
    self
  end

  private

  # Saving returns to the conventions list; waiting for its "New ..." link keeps the
  # next read from racing the redirect and seeing the form's empty table.
  def wait_for_conventions = page.find_link(CONVENTIONS_LINK)

  def row(text) = page.find(ROWS, text: text)

  def page
    Capybara.current_session
  end
end
