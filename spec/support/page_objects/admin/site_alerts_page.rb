# frozen_string_literal: true

require_relative 'rich_text'

# Selectors, navigation and form filling for admin site alert management
# (app/views/admin/site_alerts/). The message is Summernote-backed.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host.
class AdminSiteAlertsPage
  include ListTexts

  include AdminRichText

  INDEX_PATH = '/admin/site_alerts'
  ROWS = 'table tbody tr'
  INDEX_HEADING = 'h1'
  INDEX_TITLE = 'Site Alerts'
  # The list renders level, message and published, then the icon columns.
  LEVEL_CELL = 'td:nth-child(1)'
  MESSAGE_CELL = 'td:nth-child(2)'
  EDIT_LINK = 'a .fa-edit'

  def visit_index
    page.visit(INDEX_PATH)
    self
  end

  def levels = texts_for("#{ROWS} #{LEVEL_CELL}")

  def messages = texts_for("#{ROWS} #{MESSAGE_CELL}")

  def open_new
    page.click_link('New Site Alert')
    self
  end

  def create(machine_name:, message:, level: 'warning', published: true)
    visit_index.open_new
    page.select(level, from: 'site_alert_level')
    page.fill_in('site_alert_machine_name', with: machine_name)
    type_into_editor(message)
    # `.form-check input` is visually hidden (components/users.scss), so the
    # label is what a person clicks.
    page.check('site_alert_published', allow_label_click: true) if published
    page.click_button('Save')
    page.find(INDEX_HEADING, text: INDEX_TITLE)
    self
  end

  # Rows carry no machine name, so they are located by their message.
  def edit(message)
    page.find(ROWS, text: message).find(EDIT_LINK).click
    self
  end

  private

  def page
    Capybara.current_session
  end
end
