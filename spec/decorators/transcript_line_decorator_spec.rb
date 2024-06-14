require 'rails_helper'

RSpec.describe TranscriptLineDecorator do
  let(:decorator) { described_class.new(transcript_line) }
  let(:transcript_line) { create(:transcript_line) }

  describe '#search_title' do
    subject(:search_title) { decorator.search_title }

    let(:expectation) do
      "#{transcript_line.transcript.decorate.collection_title}"\
      " - #{transcript_line.transcript.title}"
    end

    it { is_expected.to eq expectation }
  end

  describe '#image_url' do
    subject(:image_url) { decorator.image_url }

    it { is_expected.to eq transcript_line.transcript.image_url }
  end

  describe '#humanize_duration' do
    subject(:humanize_duration) { decorator.humanize_duration(12345) }

    it { is_expected.to eq '(3h 25m 45s)' }
  end
end
