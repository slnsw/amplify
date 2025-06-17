# frozen_string_literal: true

class CreatePublicPages < ActiveRecord::Migration[5.2]
  def change
    create_table :public_pages do |t|
      t.integer :page_id
      t.string :content

      t.timestamps
    end

    # populate with existing pages for the
    # first time
    Page.all.each do |page|
      PaperTrail.request.disable_model(PublicPage) do
        PublicPage.new(page_id: page.id, content: page.content).save!
      end
    end
  end
end
