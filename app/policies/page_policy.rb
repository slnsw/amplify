class PagePolicy < ApplicationPolicy
  attr_reader :user, :page

  def initialize(user, page)
    @user = user
    @page = page
  end

  def index?
    @user.isAdmin?
  end

  def update?
    @user.isAdmin?
  end

  def show?
    @user.isAdmin?
  end

  def destroy?
    @user.isAdmin?
  end

  class Scope < Scope
    def resolve
      if @user.isAdmin?
        Page.all
      end
    end
  end
end
