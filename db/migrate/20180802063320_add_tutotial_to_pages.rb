# frozen_string_literal: true

class AddTutotialToPages < ActiveRecord::Migration[5.2]
  def change
    # move_out_of_migration
    page = Page.new(content: 'Tutorial', page_type: 'tutorial', published: false)
    page.save
    PublicPage.create(page: page, content: page.content)
  end
end
