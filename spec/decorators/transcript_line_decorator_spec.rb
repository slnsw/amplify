# frozen_string_literal: true

RSpec.describe TranscriptLineDecorator, type: :decorator do
  let(:collection) { create(:collection, title: 'Test Collection') }
  let(:transcript) { create(:transcript, collection: collection, title: 'Test Transcript') }
  let(:transcript_line) { create(:transcript_line, transcript: transcript) }
  let(:decorator) { transcript_line.decorate }

  describe '#search_title' do
    it 'returns formatted search title' do
      expect(decorator.search_title).to eq('Test Collection - Test Transcript')
    end
  end

  describe '#image_url' do
    it 'returns the transcript image url' do
      allow(transcript).to receive(:image_url).and_return('https://example.com/image.jpg')
      expect(decorator.image_url).to eq('https://example.com/image.jpg')
    end
  end

  describe '#humanize_duration' do
    it 'returns formatted duration when duration is positive' do
      allow(decorator).to receive(:h).and_return(double(display_time: '00:05'))
      expect(decorator.humanize_duration(5)).to eq('(00:05)')
    end

    it 'returns nil when duration is zero' do
      expect(decorator.humanize_duration(0)).to be_nil
    end

    it 'returns nil when duration is negative' do
      expect(decorator.humanize_duration(-5)).to be_nil
    end
  end
end
