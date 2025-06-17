# frozen_string_literal: true

class AddDocumentationPage < SeedMigration::Migration
  def up
    Page.create(content: 'Documentation page', page_type: 'documentation', published: true)
  end

  def down
    Page.where(page_type: 'documentation').delete_all
  end
end
