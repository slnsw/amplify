module UidValidationOnUpdate
  def uid_not_changed
    if persisted? && uid_changed?
      errors.add(:uid, "cannot be updated")
    end
  end
end
