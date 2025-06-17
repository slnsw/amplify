# frozen_string_literal: true

class InstitutionLink < ApplicationRecord
  belongs_to :institution
  validates :position, presence: true
end
