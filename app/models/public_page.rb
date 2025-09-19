class PublicPage < ApplicationRecord
  has_paper_trail
  belongs_to :page
end
