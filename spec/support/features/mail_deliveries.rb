# frozen_string_literal: true

# Captures mail in feature specs (`:mail`).
#
# config/initializers/mailer_initializer.rb sets ActionMailer::Base's delivery
# method to :smtp at boot, overriding the :test method config/environments/test.rb
# asks for, so delivered mail never reaches ActionMailer::Base.deliveries. The
# test environment also leaves DEFAULT_MAILER_HOST unset, which makes a Devise
# mail's `edit_password_url` raise while rendering. Both are restored afterwards.
RSpec.configure do |config|
  config.around(:each, :mail) do |example|
    mailer = ActionMailer::Base
    delivery_method = mailer.delivery_method
    default_url_options = mailer.default_url_options
    mailer.delivery_method = :test
    mailer.default_url_options = { host: 'amplify.test' }
    mailer.deliveries.clear

    example.run
  ensure
    mailer.delivery_method = delivery_method
    mailer.default_url_options = default_url_options
  end
end
