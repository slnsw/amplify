require 'rails_helper'

RSpec.feature 'Transcript Page', sidekiq: true do
  let(:admin) { create(:user, :admin) }
  let!(:collection) { create(:collection) }
  let(:status) { double('command execution status', :success? => true) }
  let(:wav_file) { File.open(File.join(Rails.root, 'spec/fixtures/files/speech_to_text/aboutSpeechSdk.wav')) }

  describe 'upload an audio file as an admin', js: true do
    before do
      sign_in admin
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(
        a_string_including('.wav')
      ).and_return(wav_file)
    end

    it 'shows the summary page' do
      # Mock the Azure job completely to simulate completion
      allow(Azure::SpeechToTextJob).to receive(:perform_later) do |transcript_id|
        # Simulate the job running immediately and completing successfully
        transcript = Transcript.find(transcript_id)
        transcript.update_columns(
          process_status: :completed,
          process_message: nil,
          process_completed_at: Time.current
        )
        # Create the expected transcript lines
        5.times do |i|
          transcript.transcript_lines.create!(
            sequence: i,
            start_time: i * 1000,
            end_time: (i + 1) * 1000,
            text: i == 0 ? 'the speech SDK exposes many features from the speech service but not all of them' : "Line #{i + 1}"
          )
        end
      end

      visit admin_cms_path
      first('.fa-list').click
      click_on 'Create Item'
      fill_in 'Uid', with: 'test-transcript'
      fill_in 'Title', with: 'test transcript title'
      choose 'Upload with Azure'
      attach_file 'Audio file', file_fixture('speech_to_text/aboutSpeechSdk.mp3').realpath
      click_on 'Save Item'

      expect(page).to have_content 'The new transcript has been saved.'
      transcript = Transcript.last
      expect(transcript.process_status).to eq 'completed'
      expect(transcript.transcript_lines.count).to eq 5
      expect(transcript.transcript_lines.first.text).to eq 'the speech SDK exposes many features from the speech service but not all of them'
    end
  end
end
