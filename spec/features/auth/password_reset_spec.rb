# frozen_string_literal: true

require 'rails_helper'

# The reset request goes through Devise's recoverable module, which emails the
# instructions synchronously; the `:mail` tag points delivery at
# ActionMailer::Base.deliveries (spec/support/features/mail_deliveries.rb).
RSpec.feature 'Password reset', :mail do
  let(:user) { create(:user, email: 'forgotten@example.com', password: 'Password123') }

  scenario 'emails a reset link and confirms it on the sign-in page', :aggregate_failures do
    request_reset(user.email)
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_text('You will receive an email with instructions on how to reset your password')
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include('reset_password_token=')
  end

  scenario 'sends nothing for an address without an account', :aggregate_failures do
    request_reset('nobody@example.com')
    expect(page).to have_current_path('/users/password')
    expect(page).to have_text('Email not found')
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  private

  def request_reset(email)
    visit '/users/password/new'
    fill_in 'user_email', with: email
    click_button 'Send me reset password instructions'
  end
end
