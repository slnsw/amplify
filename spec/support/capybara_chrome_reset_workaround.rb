# frozen_string_literal: true

# Capybara 3.39.1 (and current master) clear storage on reset with
#   Storage.clearDataForOrigin, origin: '*'
# Chrome 158 rejects '*' as a URL, so every js: true example raises
# InvalidArgumentError from Capybara.reset_sessions! after the example block,
# reporting the failure against a passing test. Rewrite that one CDP call to
# use the real session origin instead of touching the rest of `reset!`.
module CapybaraChromeResetWorkaround
  private

  def execute_cdp(cmd, params = {})
    params = params.merge(origin: storage_origin) if cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super
  end

  def storage_origin
    if Capybara.app_host
      Capybara.app_host.chomp('/')
    else
      Capybara.current_session.server.base_url.chomp('/')
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetWorkaround)
