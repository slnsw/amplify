# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptLineDecorator do
  let(:transcript) { create(:transcript, title: 'Transcript Title') }
  let(:transcript_line) { create(:transcript_line, transcript: transcript) }
  let(:decorator) { described_class.new(transcript_line) }

  describe '#search_title' do
    it 'returns the decorated collection title and transcript title' do
      allow(transcript).to receive_message_chain(:decorate, :collection_title).and_return('Collection Title')
      expect(decorator.search_title).to eq('Collection Title - Transcript Title')
    end
  end

  describe '#image_url' do
    it "returns the transcript's image_url" do
      allow(transcript).to receive(:image_url).and_return('http://example.com/image.jpg')
      expect(decorator.image_url).to eq('http://example.com/image.jpg')
    end
  end

  describe '#humanize_duration' do
    it 'returns formatted duration if duration > 0' do
      helper = double('helper')
      allow(decorator).to receive(:h).and_return(helper)
      allow(helper).to receive(:display_time).with(123).and_return('2:03')
      expect(decorator.humanize_duration(123)).to eq('(2:03)')
    end

    it 'returns nil if duration is 0' do
      expect(decorator.humanize_duration(0)).to be_nil
    end
  end
end
