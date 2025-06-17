# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
    end
  end
end
