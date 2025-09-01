class TranscriptPolicy < ApplicationPolicy
  def destroy?
    @user.admin?
  end

  def syncable?
    @record.process_failed?
  end
end
