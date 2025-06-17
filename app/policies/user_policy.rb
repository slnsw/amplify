# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  def index?
    admin_or_content_editor?
  end

  def update?
    admin_or_content_editor?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        User.all
      elsif @user.content_editor?
        admin_role = UserRole.find_by(name: 'admin')
        User.where.not(user_role_id: admin_role.id)
            .where('institution_id = ? OR institution_id IS NULL', @user.institution_id)
            .where.not('institution_id IS NULL AND user_role_id != 0')
      else
        User.where(institution_id: @user.institution_id)
      end
    end
  end
end
