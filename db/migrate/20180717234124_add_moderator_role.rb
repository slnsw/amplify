# frozen_string_literal: true

class AddModeratorRole < ActiveRecord::Migration[5.2]
  def change
    # move_out_of_migration
    PaperTrail.request.disable_model(Page) do
      UserRole.where(
        name: 'content_editor', hiearchy: 80,
        description: 'Content editor can edit content'
      ).first_or_create
    end
  end
end
