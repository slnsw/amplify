# frozen_string_literal: true

class ChangeDocumentationPageToUserGuide < SeedMigration::Migration
  def up
    page = Page.where(page_type: 'documentation').first
    PublicPage.where(page_id: page.id).delete_all
    page.destroy
    Page.create(content: 'User Guide', page_type: 'user_guide', published: true)
  end

  def down
    Page.where(page_type: 'user_guide').delete_all
  end
end
