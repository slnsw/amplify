class SiteAlert < ApplicationRecord
  has_paper_trail
  enum :level, { status: 'status', warning: 'warning', error: 'error' }
end
