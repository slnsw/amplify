module AzuresHelper
  def stub_audio_file_convert(
    input_file: a_string_including("aboutSpeechSdk.mp3"),
    output_file: a_string_including("aboutSpeechSdk.")
  )
    expect(Open3).to receive(:capture3).with(
      "ffmpeg",
      "-i", a_string_including("aboutSpeechSdk.mp3"),
      "-ac", "1",
      "-ar", "16000",
      a_string_including("aboutSpeechSdk.")
    ).and_return([
                   "", "", double("command execution status", success?: true)
                 ])
  end

  def stub_azure_speech_to_text(
    input_file: a_string_including("aboutSpeechSdk."),
    transcript_content: file_fixture("speech_to_text/speech-to-text-script.json").read,
    error_message: "",
    status:
  )
    expect(Open3).to receive(:capture3).with(
      a_hash_including({}),
      "node",
      a_string_including("speech-to-text.js"),
      input_file,
    ).and_return([transcript_content, error_message, status])
  end
end

RSpec.configure do |config|
  config.include AzuresHelper
end
