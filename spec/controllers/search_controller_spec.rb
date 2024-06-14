require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  render_views

  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe '#index' do
    it 'visits index page' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end
end
