class SiteAlertPolicy < ApplicationPolicy
  attr_reader :user, :site_alert

  def initialize(user, site_alert)
    @user = user
    @site_alert = site_alert
  end

  def index?
    @user.isAdmin?
  end

  def update?
    @user.isAdmin?
  end

  class Scope < Scope
    def resolve
      if @user.isAdmin?
        SiteAlert.all
      end
    end
  end
end
