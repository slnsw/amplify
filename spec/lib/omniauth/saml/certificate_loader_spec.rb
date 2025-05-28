require 'rails_helper'
require Rails.root.join('lib/omniauth/saml/certificate_loader.rb')

RSpec.describe Omniauth::Saml::CertificateLoader do
  let(:pem_string) do
    <<~PEM
      -----BEGIN CERTIFICATE-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnzQw...
      -----END CERTIFICATE-----
    PEM
  end

  let(:env_params_with_string) do
    {
      'SAML_IDP_CERT' => pem_string,
      'SAML_CONSUMER_SERVICE_URL' => 'https://example.com/acs',
      'SAML_ISSUER' => 'issuer',
      'SAML_SSO_TARGET_URL' => 'https://idp.example.com/sso',
      'SAML_NAME_ID_FORMAT' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    }
  end

  describe 'initialization with SAML_IDP_CERT string' do
    it 'loads cert_data and builds certificate' do
      cert_double = instance_double(OpenSSL::X509::Certificate, to_s: 'fingerprint')
      expect(OpenSSL::X509::Certificate).to receive(:new).with(pem_string).and_return(cert_double)

      loader = described_class.new(env_params_with_string)
      expect(loader.cert_data).to eq(pem_string)
      expect(loader.certificate).to eq(cert_double)
      expect(loader.fingerprint).to eq('fingerprint')
    end
  end

  describe 'initialization with SAML_IDP_CERT_PATH' do
    let(:pem_path) { 'spec/fixtures/test_cert.pem' }
    let(:env_params_with_path) do
      env_params_with_string.except('SAML_IDP_CERT').merge('SAML_IDP_CERT_PATH' => pem_path)
    end

    it 'loads cert_data from file' do
      allow(Rails).to receive_message_chain(:root, :join).with(pem_path).and_return(pem_path)
      allow(File).to receive(:exist?).with(pem_path).and_return(true)
      allow(File).to receive(:read).with(pem_path).and_return(pem_string)
      cert_double = instance_double(OpenSSL::X509::Certificate, to_s: 'fingerprint')
      expect(OpenSSL::X509::Certificate).to receive(:new).with(pem_string).and_return(cert_double)

      loader = described_class.new(env_params_with_path)
      expect(loader.cert_data).to eq(pem_string)
      expect(loader.certificate).to eq(cert_double)
    end
  end

  describe 'config_params' do
    it 'returns merged config hash' do
      cert_double = instance_double(OpenSSL::X509::Certificate, to_s: 'fingerprint')
      allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert_double)
      loader = described_class.new(env_params_with_string)
      params = loader.config_params

      expect(params).to include(
        :assertion_consumer_service_url,
        :issuer,
        :idp_sso_target_url,
        :idp_cert,
        :idp_cert_fingerprint,
        :idp_cert_fingerprint_validator,
        :name_identifier_format,
        :request_path,
        :callback_path
      )
      expect(params[:idp_cert]).to eq(pem_string)
      expect(params[:idp_cert_fingerprint]).to eq('fingerprint')
    end
  end

  describe 'string takes precedence over file' do
    let(:env_params_both) do
      env_params_with_string.merge('SAML_IDP_CERT_PATH' => 'some/path.pem')
    end

    it 'uses SAML_IDP_CERT string even if file path is present' do
      allow(Rails).to receive_message_chain(:root, :join)
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:read)
      cert_double = instance_double(OpenSSL::X509::Certificate, to_s: 'fingerprint')
      expect(OpenSSL::X509::Certificate).to receive(:new).with(pem_string).and_return(cert_double)

      loader = described_class.new(env_params_both)
      expect(loader.cert_data).to eq(pem_string)
    end
  end
end
