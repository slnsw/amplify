# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pua do
  let(:mock_client) { double('PopUpArchive::Client') }
  let(:pua) { described_class.new }

  before do
    ENV['PUA_CLIENT_ID'] = 'test_client_id'
    ENV['PUA_CLIENT_SECRET'] = 'test_client_secret'
    allow_any_instance_of(described_class).to receive(:_getClient).and_return(mock_client)
  end

  after do
    ENV.delete('PUA_CLIENT_ID')
    ENV.delete('PUA_CLIENT_SECRET')
  end

  describe '#initialize' do
    it 'creates a PopUpArchive client' do
      expect(pua.instance_variable_get(:@client)).to eq(mock_client)
    end
  end

  describe '#createAudioFile' do
    let(:transcript) { double('transcript', audio_url: 'http://example.com/audio.mp3', :[] => 'http://example.com/audio.mp3') }
    let(:pua_item) { { 'id' => '123' } }
    let(:transcript_status) { double('transcript_status', :[] => 1, id: 1) }

    before do
      allow(TranscriptStatus).to receive(:find_by_name).with('audio_uploaded').and_return(transcript_status)
      allow(mock_client).to receive(:create_audio_file)
      allow(transcript).to receive(:update)
    end

    context 'when audio_url is present' do
      it 'creates an audio file via client' do
        expect(mock_client).to receive(:create_audio_file).with(pua_item,
                                                                { remote_file_url: 'http://example.com/audio.mp3' })
        pua.createAudioFile(transcript, pua_item)
      end

      it 'updates transcript status to audio_uploaded' do
        pua.createAudioFile(transcript, pua_item)
        expect(transcript).to have_received(:update).with(transcript_status_id: 1)
      end

      it 'prints upload message' do
        expect { pua.createAudioFile(transcript, pua_item) }.to output(/Uploaded audio file/).to_stdout
      end
    end

    context 'when audio_url is empty' do
      let(:transcript) { double('transcript', audio_url: '', :[] => '') }

      it 'does not create audio file' do
        expect(mock_client).not_to receive(:create_audio_file)
        pua.createAudioFile(transcript, pua_item)
      end
    end
  end

  describe '#createCollection' do
    let(:collection) do
      double('collection', :[] => 'Test Description', title: 'Test Collection', description: 'Test Description')
    end
    let(:response_body) { { 'id' => '456' } }
    let(:mock_response) { double('response', http_resp: double(body: response_body)) }

    before do
      allow(mock_client).to receive(:post).and_return(mock_response)
      allow(collection).to receive(:update)
    end

    it 'posts collection data to API' do
      expect(mock_client).to receive(:post).with('/collections', anything)
      pua.createCollection(collection)
    end

    it 'updates collection vendor_identifier' do
      pua.createCollection(collection)
      expect(collection).to have_received(:update).with(vendor_identifier: '456')
    end

    it 'returns the collection' do
      result = pua.createCollection(collection)
      expect(result).to eq(collection)
    end
  end

  describe '#createItem' do
    let(:collection) { double('collection') }
    let(:pua_collection) { { 'id' => 'coll123' } }
    let(:pua_item) { { 'id' => 'item123', 'audio_files' => [] } }

    before do
      allow(collection).to receive(:[]).with(:vendor_identifier).and_return('coll123')
      allow(mock_client).to receive(:get_collection).and_return(pua_collection)
      allow(mock_client).to receive(:create_item).and_return(pua_item)
      allow(pua).to receive(:createAudioFile)
    end

    context 'when transcript has no vendor_identifier' do
      let(:transcript) { double('transcript', collection: collection) }

      before do
        allow(transcript).to receive(:[]).with(:vendor_identifier).and_return('')
        allow(transcript).to receive(:[]).with(:title).and_return('Test Title')
        allow(transcript).to receive(:[]).with(:description).and_return('Test Description')
        allow(transcript).to receive(:update)
      end

      it 'creates a new item' do
        expect(mock_client).to receive(:create_item).with(pua_collection, hash_including(title: 'Test Title'))
        pua.createItem(transcript)
      end

      it 'updates transcript vendor_identifier' do
        pua.createItem(transcript)
        expect(transcript).to have_received(:update).with(vendor_identifier: 'item123')
      end

      it 'attempts to upload audio file' do
        expect(pua).to receive(:createAudioFile).with(transcript, pua_item)
        pua.createItem(transcript)
      end
    end

    context 'when transcript has vendor_identifier' do
      let(:transcript) { double('transcript', collection: collection) }
      let(:existing_item) { { 'id' => 'existing123', 'audio_files' => [] } }

      before do
        allow(transcript).to receive(:[]).with(:vendor_identifier).and_return('existing123')
        allow(pua).to receive(:getItem).and_return(existing_item)
      end

      it 'retrieves existing item' do
        expect(pua).to receive(:getItem).with(transcript)
        pua.createItem(transcript)
      end

      context 'when item has no audio files' do
        it 'uploads audio files' do
          expect(pua).to receive(:createAudioFile).with(transcript, existing_item)
          pua.createItem(transcript)
        end
      end

      context 'when item has audio files' do
        let(:existing_item) { { 'id' => 'existing123', 'audio_files' => [{ 'id' => 'audio1' }] } }

        it 'does not upload audio files' do
          expect(pua).not_to receive(:createAudioFile)
          pua.createItem(transcript)
        end
      end
    end
  end

  describe '#get' do
    let(:response_body) { { 'data' => 'test' } }
    let(:mock_response) { double('response', http_resp: double(body: response_body)) }

    before do
      allow(mock_client).to receive(:get).and_return(mock_response)
    end

    it 'makes GET request via client' do
      expect(mock_client).to receive(:get).with('/test', { param: 'value' })
      pua.get('/test', { param: 'value' })
    end

    it 'returns response body' do
      result = pua.get('/test')
      expect(result).to eq(response_body)
    end
  end

  describe '#getCollections' do
    let(:collections_data) { [{ 'id' => '1' }, { 'id' => '2' }] }
    let(:response) { { 'collections' => collections_data } }

    before do
      allow(pua).to receive(:get).and_return(response)
    end

    it 'retrieves collections from API' do
      expect(pua).to receive(:get).with('/collections')
      pua.getCollections
    end

    it 'returns collections array' do
      result = pua.getCollections
      expect(result).to eq(collections_data)
    end
  end

  describe '#getCollection' do
    let(:collection) { double('collection', vendor_identifier: 'coll123', :[] => 'coll123') }
    let(:pua_collection) { { 'id' => 'coll123' } }

    before do
      allow(mock_client).to receive(:get_collection).and_return(pua_collection)
    end

    it 'retrieves collection via client' do
      expect(mock_client).to receive(:get_collection).with('coll123')
      pua.getCollection(collection)
    end
  end

  describe '#getItem' do
    let(:collection) { double('collection', vendor_identifier: 'coll123', :[] => 'coll123') }
    let(:transcript) { double('transcript', collection: collection, vendor_identifier: 'trans123', :[] => 'trans123') }

    before do
      allow(pua).to receive(:getItemByIds)
    end

    it 'delegates to getItemByIds' do
      expect(pua).to receive(:getItemByIds).with('coll123', 'trans123')
      pua.getItem(transcript)
    end
  end

  describe '#getItemByIds' do
    let(:item) { { 'id' => 'item123' } }

    before do
      allow(mock_client).to receive(:get_item).and_return(item)
    end

    it 'retrieves item via client' do
      expect(mock_client).to receive(:get_item).with('coll123', 'trans123')
      pua.getItemByIds('coll123', 'trans123')
    end
  end

  describe '#post' do
    let(:data) { { key: 'value' } }
    let(:response_body) { { 'result' => 'success' } }
    let(:mock_response) { double('response', http_resp: double(body: response_body)) }

    before do
      allow(mock_client).to receive(:post).and_return(mock_response)
    end

    it 'posts JSON data via client' do
      expect(mock_client).to receive(:post).with('/endpoint', JSON.generate(data))
      pua.post('/endpoint', data)
    end

    it 'returns response body' do
      result = pua.post('/endpoint', data)
      expect(result).to eq(response_body)
    end
  end
end
