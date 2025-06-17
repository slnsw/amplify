# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  attr_reader :user, :collection

  def initialize(user, collection)
    @user = user
    @collection = collection
  end

  def index?
    admin_or_content_editor?
  end

  def show?
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
        Collection.all
      else
        Collection.where(institution_id: @user.institution_id)
      end
    end
  end
end
