# frozen_string_literal: true

class ThemePolicy < ApplicationPolicy
  attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  def index?
    @user.admin?
  end

  def new?
    @user.admin?
  end

  def create?
    @user.admin?
  end

  def edit?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def destroy?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        Theme.all
      else
        Theme.none
      end
    end
  end
end
