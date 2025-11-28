# frozen_string_literal: true

RSpec.describe AmplifyBaseController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  it 'inherits from ActionController::Base' do
    expect(described_class.superclass).to eq(ActionController::Base)
  end

  it 'includes Authentication concern' do
    expect(described_class.ancestors).to include(Authentication)
  end

  describe 'authentication' do
    context 'when user is not authenticated' do
      it 'requires authentication' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }

      before { sign_in user }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
