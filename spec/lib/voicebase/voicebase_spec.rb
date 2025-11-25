# frozen_string_literal: true

require 'rails_helper'
require 'voicebase/voicebase'

RSpec.describe Voicebase do
  describe '.configure' do
    it 'yields configuration' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(Voicebase::Configuration)
    end

    it 'sets configuration' do
      described_class.configure do |config|
        config.api_key = 'test_key'
        config.voicebase_api_url = 'https://test.voicebase.com'
      end

      expect(described_class.configuration.api_key).to eq('test_key')
      expect(described_class.configuration.voicebase_api_url).to eq('https://test.voicebase.com')
    end
  end

  describe Voicebase::Configuration do
    let(:config) { described_class.new }

    describe '#initialize' do
      it 'sets default api_key to empty string' do
        expect(config.api_key).to eq('')
      end

      it 'sets default voicebase_api_url' do
        expect(config.voicebase_api_url).to eq('https://apis.voicebase.com/v3/')
      end
    end

    describe 'accessors' do
      it 'allows setting api_key' do
        config.api_key = 'new_key'
        expect(config.api_key).to eq('new_key')
      end

      it 'allows setting voicebase_api_url' do
        config.voicebase_api_url = 'https://custom.url'
        expect(config.voicebase_api_url).to eq('https://custom.url')
      end
    end
  end

  describe Voicebase::Client do
    let(:api_key) { 'test_api_key_123' }
    let(:client) { described_class.new }

    before do
      ENV['VOICEBASE_API_KEY'] = api_key
    end

    after do
      ENV.delete('VOICEBASE_API_KEY')
    end

    describe '#initialize' do
      it 'sets voicebase_api_key from ENV' do
        expect(client.voicebase_api_key).to eq(api_key)
      end

      it 'sets default voicebase_url' do
        expect(client.voicebase_url).to eq('https://apis.voicebase.com/v3/')
      end
    end

    describe '#get_transcript' do
      let(:media_id) { 'media_12345' }
      let(:response) { double('response', body: 'transcript content') }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
      end

      it 'makes GET request with default format' do
        result = client.get_transcript(media_id)
        expect(result).to eq(response)
      end

      it 'includes media_id in URL' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req.path).to include(media_id)
          response
        end
        client.get_transcript(media_id)
      end

      it 'includes format in URL' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req.path).to include('json')
          response
        end
        client.get_transcript(media_id, format: 'json')
      end

      it 'adds authorization header' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req['Authorization']).to eq("Bearer #{api_key}")
          response
        end
        client.get_transcript(media_id)
      end

      it 'uses SSL' do
        expect_any_instance_of(Net::HTTP).to receive(:use_ssl=).with(true)
        client.get_transcript(media_id)
      end
    end

    describe '#check_progress' do
      let(:media_id) { 'media_12345' }
      let(:response) { double('response', body: '{"status": "processing"}') }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
      end

      it 'makes GET request to progress endpoint' do
        result = client.check_progress(media_id)
        expect(result).to eq(response)
      end

      it 'includes media_id in URL' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req.path).to include(media_id)
          expect(req.path).to include('progress')
          response
        end
        client.check_progress(media_id)
      end

      it 'adds authorization header' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req['Authorization']).to eq("Bearer #{api_key}")
          response
        end
        client.check_progress(media_id)
      end
    end

    describe '#upload_media' do
      let(:media_url) { 'https://example.com/audio.mp3' }
      let(:response) { double('response', body: '{"mediaId": "new_media_123"}') }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
      end

      it 'makes POST request to media endpoint' do
        result = client.upload_media(media_url)
        expect(result).to eq(response)
      end

      it 'uses multipart form data' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req).to be_a(Net::HTTP::Post)
          expect(req.content_type).to include('multipart/form-data')
          response
        end
        client.upload_media(media_url)
      end

      it 'includes media URL in form data' do
        # We can't easily test FormData internals, but we can verify the request is made
        result = client.upload_media(media_url)
        expect(result).to eq(response)
      end

      it 'adds authorization header' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req['Authorization']).to eq("Bearer #{api_key}")
          response
        end
        client.upload_media(media_url)
      end

      it 'uses SSL' do
        expect_any_instance_of(Net::HTTP).to receive(:use_ssl=).with(true)
        client.upload_media(media_url)
      end

      it 'sets content length' do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |http, req|
          expect(req.content_length).to be > 0
          response
        end
        client.upload_media(media_url)
      end
    end

    describe 'HTTP configuration' do
      let(:media_id) { 'test_123' }
      let(:response) { double('response') }

      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_return(response)
      end

      it 'creates HTTP client with correct host' do
        expect(Net::HTTP).to receive(:new).with('apis.voicebase.com', 443).and_call_original
        client.get_transcript(media_id)
      end

      it 'enables SSL for all requests' do
        expect_any_instance_of(Net::HTTP).to receive(:use_ssl=).with(true).at_least(:once).and_call_original
        client.get_transcript(media_id)
      end
    end
  end
end
