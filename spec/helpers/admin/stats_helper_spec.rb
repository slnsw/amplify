# frozen_string_literal: true

RSpec.describe Admin::StatsHelper, type: :helper do
  describe '#display_name' do
    it 'humanizes key' do
      expect(helper.display_name(:user_count)).to eq('User count')
    end

    it 'handles symbols' do
      expect(helper.display_name(:total_edits)).to eq('Total edits')
    end
  end

  describe '#number_to_read' do
    it 'formats thousands with K+' do
      result = helper.number_to_read(1500)
      expect(result).to include('K')
    end

    it 'formats numbers without units for small numbers' do
      result = helper.number_to_read(500)
      expect(result).to be_present
    end
  end

  describe '#link_to_line' do
    let(:transcript) { double(path: '/transcript/123') }
    let(:line) { double(start_time: 100) }

    before do
      allow(helper).to receive(:time_display).with(100).and_return('00:01:40')
      allow(helper).to receive(:content_tag).and_call_original
    end

    it 'creates link to transcript with timestamp' do
      result = helper.link_to_line(line, transcript)
      expect(result).to be_present
    end

    it 'includes time display in link' do
      allow(helper).to receive(:content_tag).with(:a, hash_including(href: '/transcript/123?t=00:01:40'))
      helper.link_to_line(line, transcript)
    end
  end
end
