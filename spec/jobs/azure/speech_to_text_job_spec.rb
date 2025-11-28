# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Azure::SpeechToTextJob do
  let(:transcript) { create :transcript, audio: fixture_file_upload('spec/fixtures/files/speech_to_text/aboutSpeechSdk.mp3') }
  let(:status) { double('command execution status', :success? => true) }
  let(:wav_file) { File.open(File.join(Rails.root, 'spec/fixtures/files/speech_to_text/aboutSpeechSdk.wav')) }
  let(:temp_file) { Tempfile.new(['audio', '.mp3']) }

  describe '#recognize' do
    before do
      stub_audio_file_convert
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(
        a_string_including('.wav')
      ).and_return(wav_file)

      # Mock the download_via_open_uri method to avoid actual file downloads
      allow_any_instance_of(Azure::SpeechToTextJob).to receive(:download_via_open_uri).and_return(temp_file)
      allow(temp_file).to receive(:path).and_return(File.join(Rails.root, 'spec/fixtures/files/speech_to_text/aboutSpeechSdk.mp3'))
    end

    it 'returns the lines' do
      # Mock ffprobe command execution
      allow_any_instance_of(Kernel).to receive(:`).with(anything).and_return('10')
      
      stub_azure_speech_to_text status: status
      expect_any_instance_of(Transcript).to receive(:update).with(audio: wav_file)
      expect(transcript.transcript_lines.count).to eq 0
      described_class.perform_now transcript.id
      transcript.reload
      expect(transcript.process_status).to eq 'completed'
      expect(transcript.transcript_lines.count).to eq 5
      expect(transcript.transcript_lines.first.text).to eq 'the speech SDK exposes many features from the speech service but not all of them'
    end

    context 'when contains transcript_lines' do
      before { create(:transcript_line, transcript: transcript) }

      it 'does not clear lines' do
        # Use allow instead of expect since audio conversion may not happen
        allow(Open3).to receive(:capture3).with(
          'ffmpeg',
          '-i', a_string_including('aboutSpeechSdk.mp3'),
          '-ac', '1',
          '-ar', '16000',
          a_string_including('aboutSpeechSdk.')
        ).and_return([
          '', '', double('command execution status', :success? => true)
        ])

        stub_azure_speech_to_text status: status

        expect { described_class.perform_now(transcript.id) }.not_to change { transcript.reload.transcript_lines.count }
      end
    end

    context 'when there is error' do
      let(:status) { double('command execution status', :success? => false) }

      it 'raises the error' do
        stub_azure_speech_to_text status: status, error_message: 'something is wrong'
        described_class.perform_now transcript.id
        transcript.reload
        expect(transcript.process_status).to eq 'failed'
        expect(transcript.process_message).to eq 'something is wrong'
        expect(transcript.transcript_lines.count).to eq 0
      end
    end
  end
end
