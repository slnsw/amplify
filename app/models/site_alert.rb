class SiteAlert < ApplicationRecord
  has_paper_trail

  # TODO: Convert to integer-based enum
  enum :level, { status: 'status', warning: 'warning', error: 'error' }
end
