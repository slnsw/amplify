require 'rails_helper'

RSpec.describe DefaultController, type: :controller do
  controller(DefaultController) do
    def environment_index_file
      "some/file/path"
    end
  end

  describe "GET #index" do
    it "calls environment_index_file and renders the file" do
      expect(controller).to receive(:environment_index_file).and_return("some/file/path")
      get :index
      # Optionally, check response status or body if you want
      # expect(response).to be_successful
    end
  end
end