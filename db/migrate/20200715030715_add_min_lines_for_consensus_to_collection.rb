# frozen_string_literal: true

class AddMinLinesForConsensusToCollection < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :max_line_edits, :integer
    add_column :collections, :min_lines_for_consensus, :integer
    add_column :collections, :min_lines_for_consensus_no_edits, :integer
    add_column :collections, :min_percent_consensus, :decimal
  end
end
