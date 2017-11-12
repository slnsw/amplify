require 'rails_helper'

RSpec.describe VoiceBase::SrtParser, type: :service do
  describe 'SrtParser' do
    it 'creates lines that are useful from lines' do
      lines = [
        '1',
        '00:00:00,000 --> 00:00:01,500',
        'For www.forom.com',
        '',
        '2',
        '00:00:01,500 --> 00:00:02,500',
        '<i>Tonight\'s the night.</i>',
        '',
        '3',
        '00:00:03,000 --> 00:00:15,000',
        '<i>And it\'s going to happen',
        'again and again --</i>',
      ]

      processed_lines = VoiceBase::SrtParser.new(1, lines).lines
      expect(processed_lines.count).to eq 3

      expect(processed_lines[0][:transcript_id]).to eq(1)
      expect(processed_lines[0][:original_text]).to eq('For www.forom.com')
      expect(processed_lines[0][:sequence]).to eq(0)
      expect(processed_lines[0][:start_time]).to eq(0)
      expect(processed_lines[0][:end_time]).to eq(1500)

      expect(processed_lines[1][:original_text]).to eq('<i>Tonight\'s the night.</i>')
      expect(processed_lines[1][:sequence]).to eq(1)
      expect(processed_lines[1][:start_time]).to eq(1500)
      expect(processed_lines[1][:end_time]).to eq(2500)

      expect(processed_lines[2][:original_text]).to eq('<i>And it\'s going to happen again and again --</i>')
      expect(processed_lines[2][:sequence]).to eq(2)
      expect(processed_lines[2][:start_time]).to eq(3000)
      expect(processed_lines[2][:end_time]).to eq(15000)
    end
  end
end
