require 'rails_helper'
include Rack::Test::Methods

RSpec.describe Admin::PagesController, type: :controller do
  render_views

  let(:user) { create(:user, :admin, email: "user@email.com", password: "password") }
  let!(:page) { create(:page) }

  before { sign_in user }

  describe '#index' do
    it 'list pages' do
      get :index

      expect(response.body).to include("Pages")
      expect(response.body).to include("faq")
    end
  end

  describe '#create' do
    it 'create page' do
      params =  {
        page: {
          content: 'Any content',
          page_type: 'about',
          published: true,
          admin_access: true
        }
      }

      expect { post(:create, params: params ) }.to(
        change { Page.count }
      )
    end
  end

  describe '#edit' do
    it 'can view edit page' do
      get :edit, params: { id: page.id }

      expect(response.body).to include 'Editing Page'
      expect(response.body).to include page.page_type
      expect(response.body).to include page.content
    end
  end

  describe '#show' do
    it 'can preview page' do
      get :show, params: { id: page.id }

      expect(response.body).to include page.page_type
      expect(response.body).to include page.content
    end
  end

  describe '#update' do
    it 'update page' do
      params =  {
        id: page.id,
        page: {
          content: 'Any content',
          page_type: 'faqs',
          published: true,
          admin_access: true
        }
      }

      put(:update, params: params )

      page.reload

      expect(page.content).to eq 'Any content'
      expect(page.page_type).to eq 'faqs'
    end
  end

  describe '#destroy' do
    it 'deletes a page' do
      expect { delete :destroy, params: { id: page.id } }.to(
        change { Page.count }.by(-1)
      )
    end
  end

  describe '#upload' do
    it 'create page' do
      params =  {
        id: page.id,
        page: {
          image: Rack::Test::UploadedFile.new("spec/fixtures/image.jpg", "image/jpg")
        }
      }

      expect { post :upload, params: params }.to(
        change { CmsImageUpload.count }.by(1)
      )

      response_json = JSON.parse(response.body)
      expect(response_json['url']).to be_present
      expect(response_json['upload_id']).to be_present
    end
  end
end
