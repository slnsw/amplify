# frozen_string_literal: true

require_relative 'staging_helper'

# The staging runner drives a deployment whose pages pull media from a third-party
# CDN. If that host stops answering, a driver that waits for the load event turns
# every visit into a multi-minute stall, so the strategy is part of the runner's
# contract rather than an incidental driver detail.
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'the staging driver' do
  it 'returns control at DOMContentLoaded instead of waiting for third-party media' do
    driver = Capybara.drivers[Staging::STAGING_DRIVER].call(nil)

    expect(driver.options[:options].page_load_strategy).to eq(:eager)
  end
end
# rubocop:enable RSpec/DescribeClass
