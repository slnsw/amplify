require "rails_helper"

RSpec.describe Azure::SpeechToTextService, type: :service do
  subject { described_class.new file: file_path }

  let(:file_path) { file_fixture("speech_to_text/aboutSpeechSdk.mp3") }
  let(:status) { double("command execution status", success?: true) }

  describe "#recognize" do
    before do
      stub_audio_file_convert
    end

    it "returns the lines" do
      stub_azure_speech_to_text status: status
      result = subject.recognize
      expect(result.lines.count).to eq 5
      expect(result.lines.first["text"]).to eq "the speech SDK exposes many features from the speech service but not all of them"
    end

    it "returns wav_file" do
      stub_azure_speech_to_text status: status
      result = subject.recognize
      expect(result.wav_file_path).to be_present
      expect(result.wav_file_path).to include(".wav")
    end

    context "when there is error" do
      let(:status) { double("command execution status", success?: false) }

      it "raises the error" do
        stub_azure_speech_to_text status: status, error_message: "something is wrong"
        expect { subject.recognize }.to raise_error "something is wrong"
      end
    end
  end
end
