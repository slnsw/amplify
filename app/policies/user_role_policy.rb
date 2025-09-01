class UserRolePolicy < ApplicationPolicy
  attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  class Scope < Scope
    def resolve
      case @user.user_role.name
      when 'admin'
        UserRole.all
      when 'moderator'
        UserRole.where(name: ['moderator'])
      when 'content_editor'
        UserRole.where(name: ['guest', 'user', 'moderator', 'content_editor'])
      else
        UserRole.none
      end
    end
  end
end
