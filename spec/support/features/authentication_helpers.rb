# frozen_string_literal: true

# Signs factory-built users of a given role in for local feature specs.
#
# Local only: Devise::Test::IntegrationHelpers authenticates the next request
# this process serves, which cannot reach a browser pointed at a remote host.
# spec/staging must sign in through SignInPage with real credentials instead.
module AuthenticationHelpers
  ROLE_NAMES = {
    user: 'user', moderator: 'moderator', content_editor: 'content_editor', admin: 'admin'
  }.freeze

  # The factory trait that builds each role; `user` is the factory default.
  ROLE_TRAITS = { user: nil, moderator: :moderator, content_editor: :content_editor, admin: :admin }.freeze

  # Creates a confirmed user of `role`, signs it in, and returns it.
  def sign_in_as(role = :user)
    raise ArgumentError, "unknown role: #{role.inspect}" unless ROLE_NAMES.key?(role)

    user = create(:user, user_role: role_record(role))
    sign_in(user)
    user
  end

  private

  # `user_roles.name` is unique, so an example that already built the role must
  # not build a second one.
  def role_record(role)
    UserRole.find_by(name: ROLE_NAMES.fetch(role)) || create(:user_role, *Array(ROLE_TRAITS.fetch(role)))
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :feature
end
