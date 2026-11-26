# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'JavaScript health', :js do
  scenario 'home page boots without console errors', :smoke do
    visit root_path
    expect_no_javascript_errors
  end

  # `config/routes.rb` still declares these as "temp routes for testing new UI"
  # (V2Controller), so they have to keep booting until the redesign replaces the
  # current pages.
  #
  # `/v2/home` is deliberately absent: V2Controller#home never assigns the
  # `@institutions` its filter bar reads, so that route answers 500 today, and a
  # spec here would only enshrine it (see the task 10 report).
  %w[/v2/edit /v2/search].each do |path|
    scenario "#{path} boots without console errors" do
      visit path
      expect_no_javascript_errors
    end
  end

  # The hook (spec/support/features/javascript_errors.rb) is the only thing that
  # notices a dead bundle, and it would stop noticing silently if the browser
  # stopped exposing its console log. This runs a throwaway `:js` example that
  # logs a console error and whose own expectation passes, then requires that
  # example to have failed with that error: it can only fail through the hook's
  # after-each check.
  scenario 'the console hook fails an example whose browser logged an error', :aggregate_failures do
    probe = console_error_probe
    run_without_switching_driver { probe.run(RSpec::Core::Reporter.new(RSpec::Core::Configuration.new)) }
    result = probe.examples.first.execution_result

    expect(result.status).to eq(:failed)
    expect(result.exception&.message.to_s).to include('JavaScript console reported', 'hook self-test')
  end

  private

  # Not registered with RSpec's world, so it only runs here, and reported to a
  # private reporter so its expected failure is not counted against the suite.
  def console_error_probe
    RSpec::Core::ExampleGroup.describe('console hook probe', :js, type: :feature) do
      it('logs a console error') do
        expect { page.execute_script("console.error('hook self-test')") }.not_to raise_error
      end
    end
  end

  # Capybara's own after-each hook puts the probe back on the default driver,
  # which would leave this example's checks running against rack_test.
  def run_without_switching_driver
    driver = Capybara.current_driver
    yield
  ensure
    Capybara.current_driver = driver
  end
end
