# frozen_string_literal: true

class FlagPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def initialize(user, scope)
    @user  = user
    @scope = scope
  end
end
