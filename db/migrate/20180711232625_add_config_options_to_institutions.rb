# frozen_string_literal: true

class AddConfigOptionsToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :max_line_edits, :integer, default: 3
    add_column :institutions, :min_lines_for_consensus, :integer, default: 3
    add_column :institutions, :min_lines_for_consensus_no_edits, :integer, default: 3
    add_column :institutions, :min_percent_consensus, :decimal, default: 0.67
    add_column :institutions, :line_display_method, :string, default: 'guess'
    add_column :institutions, :super_user_hiearchy, :integer, default: 50
  end
end
