# frozen_string_literal: true

require 'rails_helper'
require 'omniauth/saml/certificate_loader'

RSpec.describe Omniauth::Saml::CertificateLoader do
  let(:cert_content) { '-----BEGIN CERTIFICATE-----\nTEST CERT\n-----END CERTIFICATE-----' }
  let(:mock_certificate) { double('OpenSSL::X509::Certificate', to_s: 'fingerprint123') }

  before do
    allow(OpenSSL::X509::Certificate).to receive(:new).and_return(mock_certificate)
  end

  let(:env_params) do
    {
      'SAML_CONSUMER_SERVICE_URL' => 'https://example.com/saml/consume',
      'SAML_ISSUER' => 'https://example.com',
      'SAML_SSO_TARGET_URL' => 'https://idp.example.com/sso',
      'SAML_NAME_ID_FORMAT' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
      'SAML_IDP_CERT' => cert_content
    }
  end

  describe '#initialize' do
    context 'when SAML_IDP_CERT is provided' do
      it 'loads certificate from string' do
        loader = described_class.new(env_params)
        expect(loader.cert_data).to eq(cert_content)
      end

      it 'creates OpenSSL certificate' do
        loader = described_class.new(env_params)
        expect(loader.certificate).to eq(mock_certificate)
      end

      it 'generates fingerprint' do
        loader = described_class.new(env_params)
        expect(loader.fingerprint).to eq('fingerprint123')
      end
    end

    context 'when SAML_IDP_CERT_PATH is provided' do
      let(:cert_path) { 'config/certificates/test_cert.pem' }
      let(:full_path) { Rails.root.join(cert_path) }
      let(:env_params_with_file) do
        {
          'SAML_CONSUMER_SERVICE_URL' => 'https://example.com/saml/consume',
          'SAML_ISSUER' => 'https://example.com',
          'SAML_SSO_TARGET_URL' => 'https://idp.example.com/sso',
          'SAML_NAME_ID_FORMAT' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
          'SAML_IDP_CERT_PATH' => cert_path
        }
      end

      before do
        allow(File).to receive(:exist?).with(full_path).and_return(true)
        allow(File).to receive(:read).with(full_path).and_return(cert_content)
      end

      it 'loads certificate from file' do
        loader = described_class.new(env_params_with_file)
        expect(loader.cert_data).to eq(cert_content)
      end

      it 'checks if file exists' do
        described_class.new(env_params_with_file)
        expect(File).to have_received(:exist?).with(full_path)
      end
    end

    context 'when SAML_IDP_CERT_PATH points to non-existent file' do
      let(:env_params_with_missing_file) do
        {
          'SAML_CONSUMER_SERVICE_URL' => 'https://example.com/saml/consume',
          'SAML_ISSUER' => 'https://example.com',
          'SAML_SSO_TARGET_URL' => 'https://idp.example.com/sso',
          'SAML_NAME_ID_FORMAT' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
          'SAML_IDP_CERT_PATH' => 'nonexistent.pem',
          'SAML_IDP_CERT' => cert_content
        }
      end

      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'falls back to SAML_IDP_CERT string' do
        loader = described_class.new(env_params_with_missing_file)
        expect(loader.cert_data).to eq(cert_content)
      end
    end
  end

  describe '#config_params' do
    let(:loader) { described_class.new(env_params) }
    let(:config) { loader.config_params }

    it 'includes assertion_consumer_service_url' do
      expect(config[:assertion_consumer_service_url]).to eq('https://example.com/saml/consume')
    end

    it 'includes issuer' do
      expect(config[:issuer]).to eq('https://example.com')
    end

    it 'includes idp_sso_target_url' do
      expect(config[:idp_sso_target_url]).to eq('https://idp.example.com/sso')
    end

    it 'includes name_identifier_format' do
      expect(config[:name_identifier_format]).to eq('urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress')
    end

    it 'includes idp_cert' do
      expect(config[:idp_cert]).to eq(cert_content)
    end

    it 'includes idp_cert_fingerprint' do
      expect(config[:idp_cert_fingerprint]).to be_present
    end

    it 'includes custom request_path' do
      expect(config[:request_path]).to eq('/omniauth/saml')
    end

    it 'includes custom callback_path' do
      expect(config[:callback_path]).to eq('/omniauth/saml/callback')
    end

    it 'includes idp_cert_fingerprint_validator' do
      expect(config[:idp_cert_fingerprint_validator]).to be_a(Proc)
    end

    it 'includes idp_sso_target_url_runtime_params' do
      expect(config[:idp_sso_target_url_runtime_params]).to be_a(Hash)
    end
  end

  describe 'certificate loading priority' do
    context 'when both SAML_IDP_CERT and SAML_IDP_CERT_PATH are provided' do
      let(:file_cert) { "-----BEGIN CERTIFICATE-----\nFILE CERT\n-----END CERTIFICATE-----" }
      let(:env_params_both) do
        {
          'SAML_CONSUMER_SERVICE_URL' => 'https://example.com/saml/consume',
          'SAML_ISSUER' => 'https://example.com',
          'SAML_SSO_TARGET_URL' => 'https://idp.example.com/sso',
          'SAML_NAME_ID_FORMAT' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
          'SAML_IDP_CERT' => cert_content,
          'SAML_IDP_CERT_PATH' => 'config/certificates/test.pem'
        }
      end

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(file_cert)
      end

      it 'file certificate overrides string certificate' do
        loader = described_class.new(env_params_both)
        expect(loader.cert_data).to eq(file_cert)
      end
    end
  end
end
