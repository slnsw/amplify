# frozen_string_literal: true

class TranscriptPolicy < ApplicationPolicy
  def destroy?
    @user.admin?
  end

  def syncable?
    @record.process_failed?
  end
end
