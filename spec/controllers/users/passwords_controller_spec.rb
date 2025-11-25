# frozen_string_literal: true

RSpec.describe Users::PasswordsController, type: :controller do
  it 'inherits from Devise::PasswordsController' do
    expect(described_class.superclass).to eq(Devise::PasswordsController)
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    it 'renders the new password form' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end
end
