# frozen_string_literal: true

class AddInstructionsPage < ActiveRecord::Migration[5.2]
  def change
    # move_out_of_migration
    page = Page.new(content: 'Instructions', page_type: 'instructions', published: false)
    PaperTrail.request.disable_model(Page) do
      page.save
    end
    PaperTrail.request.disable_model(PublicPage) do
      PublicPage.create(page: page, content: page.content)
    end
  end
end
