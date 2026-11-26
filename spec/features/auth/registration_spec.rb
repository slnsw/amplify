# frozen_string_literal: true

require 'rails_helper'

# Sign-up is Devise's registerable module with confirmable, so an accepted form
# creates an unconfirmed account and emails the confirmation instructions.
RSpec.feature 'Registration', :mail do
  scenario 'creates the account and asks the new user to confirm their email', :aggregate_failures do
    sign_up(email: 'new.reader@example.com')
    expect(page).to have_text('A message with a confirmation link has been sent to your email address')
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.first.to).to eq(['new.reader@example.com'])
  end

  scenario 'refuses an address that already has an account', :aggregate_failures do
    create(:user, email: 'taken@example.com')
    sign_up(email: 'taken@example.com')
    expect(page).to have_text('Email has already been taken')
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  private

  def sign_up(email:)
    visit '/users/sign_up'
    fill_in 'user_name', with: 'New Reader'
    fill_in 'user_email', with: email
    fill_in 'user_password', with: 'Password123'
    fill_in 'user_password_confirmation', with: 'Password123'
    click_button 'Sign up'
  end
end
