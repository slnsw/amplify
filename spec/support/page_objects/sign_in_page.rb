# frozen_string_literal: true

# Selectors and navigation for Devise's email sign-in page (`/users/sign_in`,
# app/views/devise/sessions/new.html.erb). It deliberately has no assertions and
# no Rails/factory/DB dependency, so the remote staging layer (spec/staging) can
# drive the same object against a real host.
class SignInPage
  EMAIL_FIELD = 'login_email'
  PASSWORD_FIELD = 'login_password'
  SUBMIT_BUTTON = 'Sign in'
  # The page offers both providers as `link_to ..., method: :post`
  # (app/views/devise/shared/_links.html.erb); rails-ujs turns each into a form.
  GOOGLE_OAUTH_PATH = '/users/auth/google_oauth2'
  FACEBOOK_OAUTH_PATH = '/users/auth/facebook'

  # `Users::SessionsController` declares `invisible_captcha only: [:create]` with
  # gem defaults, and the gem treats a POST sent within `timestamp_threshold`
  # (four seconds) of the form being rendered as spam: it redirects before Devise
  # runs, so such a submission would not prove anything about the deployed flow.
  CAPTCHA_FLOOR_SECONDS = 4

  CaptchaFloorNotElapsed = Class.new(StandardError)
  FLOOR_ERROR = "invisible_captcha rejects a form submitted within #{CAPTCHA_FLOOR_SECONDS}s of its render".freeze

  def visit_path
    page.visit('/users/sign_in')
    @rendered_at = Time.current
    self
  end

  # Renders the form, then submits it the way a person does: fill in both fields
  # and press the button, posting the invisible_captcha honeypot with them.
  # `submit` waits the captcha's floor out on a driver that can wait (Selenium);
  # a rack_test example has to advance the clock over the floor itself.
  def visit_and_submit(email:, password:)
    visit_path
    submit(email: email, password: password)
  end

  def submit(email:, password:)
    wait_for_captcha_floor
    page.fill_in(EMAIL_FIELD, with: email)
    page.fill_in(PASSWORD_FIELD, with: password)
    page.click_button(SUBMIT_BUTTON)
    self
  end

  def email_field_type = page.find("##{EMAIL_FIELD}")[:type]

  def password_field_type = page.find("##{PASSWORD_FIELD}")[:type]

  private

  def page
    Capybara.current_session
  end

  # Waits out the captcha's floor by measuring elapsed time rather than sleeping
  # for a fixed period, so a caller that has already advanced the clock (e.g.
  # ActiveSupport's `travel`) is not delayed at all.
  def wait_for_captcha_floor
    return if @rendered_at.nil?

    page.document.synchronize(CAPTCHA_FLOOR_SECONDS + Capybara.default_max_wait_time,
                              errors: [CaptchaFloorNotElapsed]) do
      raise CaptchaFloorNotElapsed, FLOOR_ERROR if Time.current - @rendered_at < CAPTCHA_FLOOR_SECONDS
    end
  end
end
