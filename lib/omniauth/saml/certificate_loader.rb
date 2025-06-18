# frozen_string_literal: true

module Omniauth
  module Saml
    # Loads SAML certificates from app config.
    class CertificateLoader
      attr_reader :cert_data
      attr_reader :certificate
      attr_reader :fingerprint

      # Initialise.
      def initialize(env_params = {})
        @env_params = env_params
        @cert_data = nil
        load_string
        load_file

        @certificate = OpenSSL::X509::Certificate.new(@cert_data)
        @fingerprint = certificate.to_s
      end

      # Get parameters for Omniauth provider.
      def config_params
        app_props.merge(idp_props).merge(custom_props)
      end

      private

      def app_props
        {
          assertion_consumer_service_url: assertion_consumer_service_url,
          issuer: issuer,
          idp_sso_target_url: idp_sso_target_url,
        }
      end

      def idp_props
        {
          idp_sso_target_url_runtime_params: {
            original_request_param: :mapped_idp_param,
          },
          idp_cert: cert_data,
          idp_cert_fingerprint: fingerprint,
          idp_cert_fingerprint_validator: ->(fp) { fp },
          name_identifier_format: saml_name_id_format,
        }
      end

      def custom_props
        {
          request_path: "/omniauth/saml",
          callback_path: "/omniauth/saml/callback",
        }
      end

      def assertion_consumer_service_url
        @env_params["SAML_CONSUMER_SERVICE_URL"]
      end

      def issuer
        @env_params["SAML_ISSUER"]
      end

      def idp_sso_target_url
        @env_params["SAML_SSO_TARGET_URL"]
      end

      def saml_name_id_format
        @env_params["SAML_NAME_ID_FORMAT"]
      end

      def load_string
        return unless @env_params.key?("SAML_IDP_CERT")

        @cert_data = @env_params["SAML_IDP_CERT"]
      end

      # Loads a certificate file.
      def load_file
        return unless @env_params.key?("SAML_IDP_CERT_PATH")

        path = Rails.root.join(@env_params["SAML_IDP_CERT_PATH"])
        return unless File.exist?(path)

        @cert_data = File.read(path)
      end
    end
  end
end
