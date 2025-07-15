class SiteAlert < ApplicationRecord
  has_paper_trail

  enum :level, { status: 0, warning: 1, error: 2 }
end
