# frozen_string_literal: true

class CreateSpeakers < ActiveRecord::Migration[7.0]
  def change
    create_table :speakers do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
