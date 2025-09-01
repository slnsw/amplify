class InstitutionLink < ApplicationRecord
  belongs_to :institution
  validates_presence_of :position
end
