# frozen_string_literal: true

require 'omniauth/saml/certificate_loader'

# Initialise Omniauth config.
Rails.application.config.middleware.use OmniAuth::Builder do
  # Google OAuth2 authentication.
  if ENV.key?('GOOGLE_CLIENT_ID') && ENV.key?('GOOGLE_CLIENT_SECRET')
    provider :google_oauth2,
             ENV['GOOGLE_CLIENT_ID'],
             ENV['GOOGLE_CLIENT_SECRET'],
             skip_jwt: true
  end

  # Facebook authentication.
  if ENV.key?('FACEBOOK_APP_ID') && ENV.key?('FACEBOOK_APP_SECRET')
    provider :facebook,
             ENV['FACEBOOK_APP_ID'],
             ENV['FACEBOOK_APP_SECRET']
  end

  # SAML authentication.
  if ENV.key?('SAML_CONSUMER_SERVICE_URL')
    # Load certificate and generate fingerprint.
    cl = Omniauth::Saml::CertificateLoader.new(ENV)
    provider :saml, cl.config_params
  end
end
