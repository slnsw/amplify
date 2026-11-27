# frozen_string_literal: true

require 'rails_helper'

# /admin/users lists the public users and the staff, and its role select PUTs the
# user (app/assets/javascripts/users.js -> Admin::UsersController#update). A role
# change is proved by the capability it grants.
RSpec.feature 'Admin users' do
  let(:users) { AdminUsersPage.new }
  let(:editor_role) { UserRole.find_by(name: 'content_editor') || create(:user_role, :content_editor) }
  let(:admin_role) { UserRole.find_by(name: 'admin') || create(:user_role, :admin) }

  describe 'as an admin', :js do
    before do
      editor_role
      admin_role
      sign_in_as(:admin)
    end

    scenario 'lists the registered and the staff users' do
      member = create(:user, name: 'Casey Member')
      editor = create(:user, :content_editor, name: 'Robin Editor', user_role: editor_role)

      users.visit_index

      expect(page.text(:all)).to include(member.name, editor.name)
    end

    # /admin/reports is gated by `authenticate_admin!`, so it renders only for the
    # promoted user - which is the change being proved.
    scenario 'promotes a content editor to admin, unlocking the admin reports', :aggregate_failures do
      editor = create(:user, :content_editor, user_role: editor_role)
      expect(reports_path_for(editor)).to eq('/')
      promote(editor)
      expect(reports_path_for(editor.reload)).to eq('/admin/reports')
    end
  end

  private

  def promote(user)
    sign_in_as(:admin)
    users.visit_index.open_pane_for(user).change_role(user, role: admin_role)
  end

  # The test sign-in hands Warden the in-memory record, whose `user_role` is still
  # the cached one; a real request would read the row again.
  def reports_path_for(user)
    sign_in(user)
    page.visit('/admin/reports')
    page.current_path
  end
end
