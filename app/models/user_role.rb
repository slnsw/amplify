class UserRole < ApplicationRecord
  has_paper_trail
  # any user role that is >= 3 consider as staff
  # any user role that is <= 3 consider as public users (guest and registred)
  MIN_STAFF_LEVEL = 3

  enum :transcribing_role, { registered_user: 0, admin: 1 }

  def self.getAll
    UserRole.order(:hiearchy)
  end
end
