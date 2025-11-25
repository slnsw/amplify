# frozen_string_literal: true

RSpec.describe DashboardHelper, type: :helper do
  describe '#edited_info' do
    let(:transcript) { create(:transcript) }
    let(:edits) do
      [
        double(count: 1, transcript_id: transcript.id),
        double(count: 1, transcript_id: transcript.id),
        double(count: 1, transcript_id: create(:transcript).id)
      ]
    end

    before do
      allow(helper).to receive(:display_time).with(3 * Transcript.seconds_per_line).and_return('00:30')
    end

    it 'returns HTML with edit statistics' do
      result = helper.edited_info(edits)
      expect(result).to include('3')
      expect(result).to include('2')
      expect(result).to include('00:30')
    end

    it 'includes strong tags for emphasis' do
      result = helper.edited_info(edits)
      expect(result).to include('<strong>')
    end
  end

  describe '#group_edits_by_transcripts' do
    let(:transcript1) { create(:transcript) }
    let(:transcript2) { create(:transcript) }
    let(:edit1) { double(transcript_id: transcript1.id, transcript: transcript1) }
    let(:edit2) { double(transcript_id: transcript1.id, transcript: transcript1) }
    let(:edit3) { double(transcript_id: transcript2.id, transcript: transcript2) }

    it 'groups edits by transcript_id' do
      result = helper.group_edits_by_transcripts([edit1, edit2, edit3])
      expect(result.keys).to contain_exactly(transcript1.id, transcript2.id)
      expect(result[transcript1.id][:edits]).to eq([edit1, edit2])
      expect(result[transcript2.id][:edits]).to eq([edit3])
    end

    it 'includes transcript in grouped hash' do
      result = helper.group_edits_by_transcripts([edit1])
      expect(result[transcript1.id][:transcript]).to eq(transcript1)
    end
  end

  describe '#time_in_seconds' do
    before do
      allow(helper).to receive(:display_time).with(5 * Transcript.seconds_per_line).and_return('00:50')
    end

    it 'converts time to display format' do
      result = helper.time_in_seconds(5)
      expect(result).to eq('00:50')
    end
  end

  describe '#edits_min_display' do
    it 'returns minimum edits display value' do
      expect(helper.edits_min_display).to eq(7)
    end
  end
end
