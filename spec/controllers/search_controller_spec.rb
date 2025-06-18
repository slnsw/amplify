require "rails_helper"

RSpec.describe SearchController, type: :controller do
  describe "GET #index" do
    before do
      allow(controller).to receive(:load_collections).and_return(true)
      allow(controller).to receive(:load_institutions).and_return(true)
      allow(controller).to receive(:build_params).and_return({})
      allow(TranscriptSearch).to receive_message_chain(:new, :transcripts).and_return([])
      allow(Theme).to receive_message_chain(:all, :order).and_return([])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
      expect(assigns(:page_title)).to eq("Search")
      expect(assigns(:build_params)).to eq({ page: 1 })
      expect(assigns(:transcripts)).to eq([])
      expect(assigns(:themes)).to eq([])
      expect(assigns(:form_url)).to eq(search_index_path)
    end
  end
end
