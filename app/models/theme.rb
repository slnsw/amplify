# frozen_string_literal: true

class Theme < ApplicationRecord
  has_paper_trail
  validates :name, presence: true
end
