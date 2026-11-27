# frozen_string_literal: true

RSpec.describe 'config/initializers/bugsnag.rb', type: :initializer do
  let(:initializer) { Rails.root.join('config/initializers/bugsnag.rb') }
  let(:configuration) { Bugsnag.configuration }
  let(:api_key) { 'conventional-key' }
  let(:legacy_api_key) { 'legacy-key' }
  let(:release_stage) { nil }

  around do |example|
    previous = { api_key: configuration.api_key, release_stage: configuration.release_stage }
    example.run
  ensure
    configuration.api_key = previous[:api_key]
    configuration.release_stage = previous[:release_stage]
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('BUGSNAG_API_KEY').and_return(api_key)
    allow(ENV).to receive(:[]).with('BUGSNUG_API_KEY').and_return(legacy_api_key)
    allow(ENV).to receive(:[]).with('BUGSNAG_RELEASE_STAGE').and_return(release_stage)
  end

  def load_initializer
    load initializer
  end

  it 'uses the conventional variable name' do
    load_initializer

    expect(configuration.api_key).to eq('conventional-key')
  end

  context 'when only the misspelled variable is set' do
    let(:api_key) { nil }

    it 'falls back to it' do
      load_initializer

      expect(configuration.api_key).to eq('legacy-key')
    end
  end

  context 'when the variables are set to empty strings' do
    let(:api_key) { '' }
    let(:legacy_api_key) { '' }

    it 'leaves the key unset rather than configuring a blank one' do
      load_initializer

      expect(configuration.api_key).to be_nil
    end
  end

  context 'when BUGSNAG_RELEASE_STAGE is set' do
    let(:release_stage) { 'staging' }

    it 'reports that release stage' do
      load_initializer

      expect(configuration.release_stage).to eq('staging')
    end
  end

  context 'when BUGSNAG_RELEASE_STAGE is not set' do
    it 'leaves the Rails environment as the release stage' do
      expect { load_initializer }.not_to change(configuration, :release_stage)
    end
  end
end
