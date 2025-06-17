# frozen_string_literal: true

class AddCropImageCoordinatesToTranscripts < ActiveRecord::Migration[5.2]
  def change
    add_column :transcripts, :crop_x, :integer
    add_column :transcripts, :crop_y, :integer
    add_column :transcripts, :crop_w, :integer
    add_column :transcripts, :crop_h, :integer
  end
end
