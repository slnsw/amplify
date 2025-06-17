# frozen_string_literal: true

module UidValidationOnUpdate
  def uid_not_changed
    errors.add(:uid, 'cannot be updated') if persisted? && uid_changed?
  end
end
