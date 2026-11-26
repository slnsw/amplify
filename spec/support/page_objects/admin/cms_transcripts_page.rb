# frozen_string_literal: true

require_relative 'rich_text'

# Selectors, navigation and form filling for CMS item management
# (app/views/admin/cms/collections/show.html.erb and
# app/views/admin/cms/transcripts/): the item list of a collection, its bulk
# actions, the new/edit forms, and the process/reset controls of an item whose
# script has been uploaded.
#
# It deliberately has no assertions and no factory/DB dependency, so the remote
# staging layer (spec/staging) could drive it against a real host: the records it
# is handed only have to expose `uid`.
class AdminCmsTranscriptsPage
  include AdminRichText

  COLLECTION_PATH = '/admin/cms/collections'
  NEW_PATH = '/admin/cms/transcripts/new'
  EDIT_PATH = '/admin/cms/transcripts'
  ROWS = 'table tbody tr'
  # Each item row renders the publish icon, then the title, then the image.
  ITEM_TITLE_CELL = 'th:nth-child(2)'
  # `publish_icon` (app/helpers/admin_helper.rb) picks one of the two.
  PUBLISHED_ICON = '.fa-globe'
  UNPUBLISHED_ICON = '.fa-file-text'
  LINE_COUNT = '#transcript-line-count'
  PROCESS_BUTTON = '#update-transcript'
  RESET_LINK_TEXT = 'Reset item'
  BULK_MENU_LABEL = 'Actions'
  # The collection page footer that every redirect back from an item lands on.
  TOTAL_ITEMS = '.total-items'

  def visit_collection(uid)
    page.visit("#{COLLECTION_PATH}/#{uid}")
    self
  end

  def visit_new(collection_uid)
    page.visit("#{NEW_PATH}?collection_uid=#{collection_uid}")
    self
  end

  def visit_edit(uid)
    page.visit("#{EDIT_PATH}/#{uid}/edit")
    self
  end

  def create(uid:, title:, collection_uid:, script: nil)
    visit_new(collection_uid)
    page.fill_in('transcript_uid', with: uid)
    page.fill_in('transcript_title', with: title)
    page.choose('Manual Upload')
    page.attach_file('transcript_script', script) if script
    page.click_button('Save Item')
    # Saving redirects to the collection page; wait for it so the next
    # navigation cannot race the post/redirect round trip.
    page.find(TOTAL_ITEMS)
    self
  end

  def item_titles = page.all("#{ROWS} #{ITEM_TITLE_CELL}").map(&:text)

  def published?(title) = item_row(title).has_css?(PUBLISHED_ICON)

  def unpublished?(title) = item_row(title).has_css?(UNPUBLISHED_ICON)

  # The bulk action answers with JavaScript that re-renders the row, so waiting for
  # the published icon is what proves the write finished before anything reloads.
  def await_published(title)
    item_row(title).find(PUBLISHED_ICON)
    self
  end

  def line_count = page.find(LINE_COUNT).text

  # editor.js rewrites the count from the JSON the process_transcript POST
  # answers with, so the span has to be polled for the new value.
  def await_line_count(text)
    page.find(LINE_COUNT, text: text)
    self
  end

  def process
    page.find(PROCESS_BUTTON).click
    self
  end

  def reset
    page.accept_confirm { page.click_link(RESET_LINK_TEXT) }
    page.find(TOTAL_ITEMS)
    self
  end

  def select_all_items
    page.check('select-all')
    self
  end

  def bulk_action(label)
    page.click_button(BULK_MENU_LABEL)
    page.click_button(label)
    self
  end

  private

  def item_row(title) = page.find(ROWS, text: title)

  def page
    Capybara.current_session
  end
end
