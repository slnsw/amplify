# frozen_string_literal: true

require 'rails_helper'
require 'uri'

# Email sign-in is Devise's database strategy behind a form that also carries
# InvisibleCaptcha's honeypot, so these examples submit the form the way a
# person does rather than signing the session in behind Devise's back.
RSpec.feature 'Sign in' do
  include ActiveSupport::Testing::TimeHelpers

  # rack_test follows redirects, and following this one would replay the
  # request against Google's host through the app; the OAuth entry point is
  # asserted from the response instead of by loading the provider.
  Capybara.register_driver :rack_test_no_redirects do |app|
    Capybara::RackTest::Driver.new(app, follow_redirects: false)
  end

  let(:sign_in_page) { SignInPage.new }
  let(:password) { 'Password123' }
  let(:user) { create(:user, email: 'reader@example.com', password: password) }

  before { sign_in_page.visit_path }

  scenario 'renders the email and password form with both OAuth entry points', :aggregate_failures do
    expect(sign_in_page.email_field_type).to eq('email')
    expect(sign_in_page.password_field_type).to eq('password')
    expect(page).to have_button(SignInPage::SUBMIT_BUTTON)
    expect(page).to have_link('Sign in with Google', href: SignInPage::GOOGLE_OAUTH_PATH)
    expect(page).to have_link('Sign in with Facebook', href: SignInPage::FACEBOOK_OAUTH_PATH)
  end

  # Anonymous visitors to /dashboard are sent to the sign-in page, and Devise
  # returns them there once the form is accepted.
  scenario 'signs the user in and returns them to the dashboard', :aggregate_failures, :smoke do
    visit '/dashboard'
    submit_sign_in(email: user.email, password: password)
    expect(page).to have_current_path('/dashboard')
    expect(page).to have_text('Signed in successfully.')
    expect(page).to have_text(DashboardPage::HEADING)
  end

  scenario 'rejects invalid credentials and stays on the sign-in page', :aggregate_failures do
    submit_sign_in(email: user.email, password: 'not-the-password')
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_css('#error_explanation', text: 'Invalid email or password.')
  end

  # The provider is never contacted: only the entry point's redirect is asserted.
  scenario 'sends the Google OAuth entry point to Google', :aggregate_failures,
           driver: :rack_test_no_redirects do
    page.driver.submit(:post, SignInPage::GOOGLE_OAUTH_PATH, {})

    expect(page.status_code).to eq(302)
    expect(URI.parse(page.response_headers['Location']).host).to eq('accounts.google.com')
  end

  private

  # InvisibleCaptcha treats a POST sent within four seconds of the form being
  # rendered as spam (app/controllers/users/sessions_controller.rb), and
  # rack_test's driver cannot wait, so the example advances the clock over that
  # floor rather than pausing for it — a person takes longer than four seconds.
  def submit_sign_in(email:, password:)
    travel(SignInPage::CAPTCHA_FLOOR_SECONDS + 1) { sign_in_page.submit(email: email, password: password) }
  end
end
