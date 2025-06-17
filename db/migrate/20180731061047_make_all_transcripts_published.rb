# frozen_string_literal: true

class MakeAllTranscriptsPublished < ActiveRecord::Migration[5.2]
  def change
    Transcript.all.map(&:publish!)
  end
end
