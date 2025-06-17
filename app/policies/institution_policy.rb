# frozen_string_literal: true

class InstitutionPolicy < ApplicationPolicy
  attr_reader :user, :institution

  def initialize(user, institution)
    @user = user
    @institution = institution
  end

  def index?
    admin_or_content_editor?
  end

  def new?
    @user.admin?
  end

  def create?
    @user.admin?
  end

  def edit?
    admin_or_content_editor?
  end

  def update?
    admin_or_content_editor?
  end

  def destroy?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        Institution.order_asc
      elsif @user.content_editor?
        Institution.where(id: @user.institution_id).order_asc
      else
        Institution.none
      end
    end
  end
end
