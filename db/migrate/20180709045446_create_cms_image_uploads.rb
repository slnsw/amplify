# frozen_string_literal: true

class CreateCmsImageUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :cms_image_uploads do |t|
      t.string :image

      t.timestamps
    end
  end
end
