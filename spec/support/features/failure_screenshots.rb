# frozen_string_literal: true

# Saves a screenshot of the page a failed local `:js` example left behind, so a
# CI failure can be read from the uploaded artifact (.github/workflows/rspec.yml)
# instead of reproduced. The staging layer takes its own screenshots
# (spec/staging/staging_helper.rb) and is skipped here.
#
# Defined before javascript_errors.rb (support files load alphabetically) so it
# runs after that hook: RSpec runs after-hooks in reverse order, and a failure the
# console check reports still gets its screenshot.
#
# Screenshots land in `Capybara.save_path`, which capybara/rails sets to
# tmp/capybara.
module FailureScreenshots
  module_function

  def save(example, session)
    return unless example.exception && session.driver.respond_to?(:save_screenshot)

    name = example.full_description.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')[0, 120]
    session.save_screenshot("#{name}.png")
  rescue StandardError => e
    Kernel.warn("Could not save a failure screenshot for #{example.full_description}: #{e.class}: #{e.message}")
  end
end

RSpec.configure do |config|
  config.after(:each, :js) do |example|
    next if Capybara.app.nil?

    FailureScreenshots.save(example, Capybara.current_session)
  end
end
