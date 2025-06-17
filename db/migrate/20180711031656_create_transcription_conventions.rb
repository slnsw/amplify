# frozen_string_literal: true

class CreateTranscriptionConventions < ActiveRecord::Migration[5.2]
  def change
    create_table :transcription_conventions do |t|
      t.string :convention_key
      t.string :convention_text
      t.string :example
      t.integer :institution_id

      t.timestamps
    end

    # for existing institutions
    Institution.find_each do |institution|
      TranscriptionConvention.create_default(institution.id)
    end
  end
end
