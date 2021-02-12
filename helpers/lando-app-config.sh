#!/bin/bash

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 128 | head -n 1)

CONFIG=<<EOF
SECRET_KEY_BASE: "$NEW_UUID"
PROJECT_ID: nsw-state-library-amplify
SAML_NAME_ID_FORMAT: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
RACK_ATTACK_WHITELIST: ""

staging:
  GOOGLE_CLIENT_ID: xxx
  GOOGLE_CLIENT_SECRET: xxx
  FACEBOOK_APP_ID: 'xxx'
  FACEBOOK_APP_SECRET:  xxx'
  AWS_S3_ACCESS_KEY_ID: xxx
  AWS_S3_SECRET_ACCESS_KEY: xxx
  AWS_S3_REGION: ap-southeast-2
  AWS_S3_BUCKET: slnsw-amplify-staging
  # SAML_CONSUMER_SERVICE_URL: http://xxx/omniauth/saml/callback
  # SAML_ISSUER: xxx
  # SAML_SSO_TARGET_URL: xxx
  # SAML_IDP_CERT_PATH: config/certificates/xxx
  # SENDER_EMAIL: web.development@sl.nsw.gov.au
  # SMTP_URI: xxx
  # SMTP_PORT: '587'
  # SES_SMTP_USERNAME: xxx
  # SES_SMTP_PASSWORD: xxx
  # DEFAULT_MAILER_HOST: amplify.lndo.site
  # VOICEBASE_API_KEY: xxx
  REDIS_URL: redis://redis:6379
  GOOGLE_TAG_MANAGER_ID: ""
  RACK_ATTACK_WHITELIST: ""
  SPEECH_TO_TEXT_KEY: ""
EOF

echo $CONFIG > ../config/application.yml

