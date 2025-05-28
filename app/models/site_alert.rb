class SiteAlert < ApplicationRecord
  has_paper_trail
  enum level: { status: 'status', warning: 'warning', error: 'error' }

  validates :machine_name, presence: true
  validates :message, presence: true
end
