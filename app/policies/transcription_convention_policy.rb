# frozen_string_literal: true

class TranscriptionConventionPolicy < ApplicationPolicy
  attr_reader :user, :csope

  def initialize(user, scope)
    @user = user
    @csope = scope
  end

  def index?
    admin_or_content_editor?
  end

  def new?
    admin_or_content_editor?
  end

  def create?
    admin_or_content_editor?
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
        TranscriptionConvention.all
      else
        TranscriptionConvention.where(institution_id: @user.institution_id)
                               .order_asc
      end
    end
  end
end
