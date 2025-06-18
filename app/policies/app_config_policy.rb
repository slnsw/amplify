class AppConfigPolicy < ApplicationPolicy
  attr_reader :user, :object

  def initialize(user, _institution)
    @user = user
    @object = object
  end

  def index?
    @user.admin?
  end

  def edit?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        AppConfig.find
      else
        AppConfig.none
      end
    end
  end
end
