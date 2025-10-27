# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DefaultController, type: :controller do
  describe '#index' do
    let(:env_file) { "public/#{ENV.fetch('PROJECT_ID', nil)}/index.html" }

    before do
      allow(controller).to receive(:environment_file).with('index').and_return(env_file)
      allow(controller).to receive(:render)
    end

    it 'renders the environment index file' do
      # call the action method directly to avoid routing
      controller.send(:index)
      expect(controller).to have_received(:render).with(file: env_file)
    end
  end
end
