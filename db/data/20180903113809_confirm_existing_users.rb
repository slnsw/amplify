# frozen_string_literal: true

class ConfirmExistingUsers < SeedMigration::Migration
  def up
    User.where(confirmed_at: nil).find_each do |user|
      user.skip_confirmation!
      user.skip_confirmation_notification!
      user.save
    end
  end

  def down; end
end
