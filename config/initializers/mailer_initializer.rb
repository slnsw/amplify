# frozen_string_literal: true

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: ENV['SMTP_URI'],
  port: ENV['SMTP_PORT'],
  user_name: ENV['SES_SMTP_USERNAME'],
  password: ENV['SES_SMTP_PASSWORD'],
  authentication: :login,
  enable_starttls_auto: true
}
