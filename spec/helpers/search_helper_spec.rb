# frozen_string_literal: true

RSpec.describe SearchHelper, type: :helper do
  describe '#item_tag' do
    let(:transcript) { double(guess_text: '') }

    context 'when query is not blank' do
      it 'returns computer-generated text tag when guess_text is empty' do
        result = helper.item_tag(transcript, 'search query')
        expect(result).to include('computer-generated text')
      end

      it 'returns user-generated text tag when guess_text is present' do
        allow(transcript).to receive(:guess_text).and_return('some text')
        result = helper.item_tag(transcript, 'search query')
        expect(result).to include('user-generated text')
      end
    end

    context 'when query is blank' do
      it 'returns nil' do
        expect(helper.item_tag(transcript, '')).to be_nil
      end
    end
  end

  describe '#search_text' do
    let(:transcript_obj) { double(decorate: double(path: '/test-path')) }
    let(:transcript) do
      double(transcript: transcript_obj, start_time: 100, guess_text: 'test text', original_text: 'original')
    end

    before do
      allow(helper).to receive(:time_display).and_return('00:01:40')
      allow(helper).to receive(:content_tag).and_call_original
    end

    context 'when query is not blank' do
      it 'returns a link with the text' do
        result = helper.search_text(transcript, 'query')
        expect(result).to be_present
      end

      context 'when guess_text is empty' do
        before { allow(transcript).to receive(:guess_text).and_return('') }

        it 'uses original_text' do
          result = helper.search_text(transcript, 'query')
          expect(result).to be_present
        end
      end
    end

    context 'when query is blank' do
      it 'returns nil' do
        expect(helper.search_text(transcript, '')).to be_nil
      end
    end
  end
end
