# frozen_string_literal: true

RSpec.describe PageHelper, type: :helper do
  describe '#themes_checked?' do
    let(:theme) { double(object: double(name: 'test-theme')) }

    context 'when @build_params[:themes] is an array' do
      before { helper.instance_variable_set(:@build_params, { themes: ['test-theme'] }) }

      it 'returns true if theme is in params' do
        expect(helper.themes_checked?(theme)).to be true
      end
    end

    context 'when @build_params[:themes] is not an array' do
      before { helper.instance_variable_set(:@build_params, { themes: 'not-array' }) }

      it 'returns nil' do
        expect(helper.themes_checked?(theme)).to be_nil
      end
    end
  end

  describe '#collection_checked?' do
    let(:collection) { double(object: double(title: 'Test Collection')) }

    context 'when @build_params[:collections] is an array' do
      before { helper.instance_variable_set(:@build_params, { collections: ['Test Collection'] }) }

      it 'returns true if collection is in params' do
        expect(helper.collection_checked?(collection)).to be true
      end
    end

    context 'when @build_params[:collections] is not an array' do
      before { helper.instance_variable_set(:@build_params, { collections: nil }) }

      it 'returns nil' do
        expect(helper.collection_checked?(collection)).to be_nil
      end
    end
  end

  describe '#search_themes_checked?' do
    let(:theme) { double(object: double(name: 'search-theme')) }

    context 'when params dig data theme is an array' do
      before { allow(helper).to receive(:params).and_return({ data: { theme: ['search-theme'] } }) }

      it 'returns true if theme is in params' do
        expect(helper.search_themes_checked?(theme)).to be true
      end
    end
  end

  describe '#search_collection_checked?' do
    let(:collection) { double(object: double(id: 123)) }

    context 'when params dig data collection_id is an array' do
      before { allow(helper).to receive(:params).and_return({ data: { collection_id: ['123'] } }) }

      it 'returns true if collection id is in params' do
        expect(helper.search_collection_checked?(collection)).to be true
      end
    end
  end
end
