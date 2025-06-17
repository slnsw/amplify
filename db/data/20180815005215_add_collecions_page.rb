# frozen_string_literal: true

class AddCollecionsPage < SeedMigration::Migration
  def up
    Page.create(content: 'Collections page', page_type: 'collections')
  end

  def down
    Page.where(page_type: 'collections').delete_all
  end
end
