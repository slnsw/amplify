# frozen_string_literal: true

RSpec.describe Users::RegistrationsController, type: :controller do
  it 'inherits from Devise::RegistrationsController' do
    expect(described_class.superclass).to eq(Devise::RegistrationsController)
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#configure_sign_up_params' do
    it 'permits name parameter' do
      controller = described_class.new
      allow(controller).to receive(:devise_parameter_sanitizer).and_return(double(permit: true))
      controller.send(:configure_sign_up_params)
      expect(controller).to have_received(:devise_parameter_sanitizer)
    end
  end

  describe 'GET #new' do
    it 'renders sign up form' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end
end
