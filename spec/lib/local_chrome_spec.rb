# frozen_string_literal: true

RSpec.describe LocalChrome do
  describe '.service' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('CHROME_DRIVER_PATH').and_return(path)
    end

    context 'when CHROME_DRIVER_PATH is not set' do
      let(:path) { nil }

      it 'leaves driver resolution to Selenium Manager' do
        expect(described_class.service).to be_nil
      end
    end

    context 'when CHROME_DRIVER_PATH points at a file that is not there' do
      let(:path) { '/opt/homebrew/bin/chromedriver-not-installed' }

      it 'ignores it rather than failing every :js example' do
        expect(described_class.service).to be_nil
      end
    end

    context 'when CHROME_DRIVER_PATH points at an executable' do
      let(:path) { RbConfig.ruby }

      it 'pins that binary' do
        expect(described_class.service.executable_path).to eq(RbConfig.ruby)
      end
    end
  end
end
