# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageController, type: :controller do
  describe '#show' do
    context 'when page is public' do
      let!(:page) { create(:page, page_type: 'custom', admin_access: false) }
      let!(:public_page) { create(:public_page, page: page, content: 'public content') }

      before do
        get :show, params: { id: 'custom' }
      end

      it 'renders the show template' do
        expect(response).to render_template('page/show')
      end

      it 'uses the application_v2 layout' do
        expect(response).to render_template(layout: 'application_v2')
      end

      it 'assigns @public_page with decorated page' do
        expect(assigns(:public_page)).to be_instance_of(PublicPageDecorator)
      end

      it 'decorated object is the created public_page' do
        expect(assigns(:public_page).object).to eq(public_page)
      end

      it 'sets the page title from the key when not set' do
        expect(assigns(:page_title)).to eq('Custom')
      end
    end

    context 'when page requires admin access and user is not staff' do
      before do
        create(:page, page_type: 'admin-only', admin_access: true)

        get :show, params: { id: 'admin-only' }
      end

      it 'renders the no_access template' do
        expect(response).to render_template('page/no_access')
      end

      it 'uses the application_v2 layout' do
        expect(response).to render_template(layout: 'application_v2')
      end
    end

    context 'when page requires admin access and user is staff' do
      let!(:admin_page) { create(:page, page_type: 'admin-only-staff', admin_access: true) }
      let!(:public_page) { create(:public_page, page: admin_page) }
      let!(:staff_user) { create(:user, :admin) }

      before do
        allow(controller).to receive(:current_user).and_return(staff_user)

        get :show, params: { id: admin_page.page_type }
      end

      it 'renders the show template' do
        expect(response).to render_template('page/show')
      end

      it 'uses the application_v2 layout' do
        expect(response).to render_template(layout: 'application_v2')
      end

      it 'decorated object is the created public_page for admin-staff' do
        expect(assigns(:public_page).object).to eq(public_page)
      end
    end
  end

  describe '#faq' do
    let!(:page) { create(:page, page_type: 'faq', admin_access: false) }
    let!(:public_page) { create(:public_page, page: page) }

    before { get :faq }

    it 'sets the FAQ page title' do
      expect(assigns(:page_title)).to eq('Frequently Asked Questions')
    end

    it 'renders the show template' do
      expect(response).to render_template('page/show')
    end

    it 'uses the application_v2 layout' do
      expect(response).to render_template(layout: 'application_v2')
    end

    it 'decorated object is the created public_page for faq' do
      expect(assigns(:public_page).object).to eq(public_page)
    end
  end

  describe '#about' do
    let!(:page) { create(:page, page_type: 'about', admin_access: false) }
    let!(:public_page) { create(:public_page, page: page) }

    before { get :about }

    it 'renders the show template' do
      expect(response).to render_template('page/show')
    end

    it 'uses the application_v2 layout' do
      expect(response).to render_template(layout: 'application_v2')
    end

    it 'decorated object is the created public_page for about' do
      expect(assigns(:public_page).object).to eq(public_page)
    end
  end

  describe '#tutotial' do
    let!(:page) { create(:page, page_type: 'tutorial', admin_access: false) }
    let!(:public_page) { create(:public_page, page: page) }

    before { get :tutotial }

    it 'renders the show template' do
      expect(response).to render_template('page/show')
    end

    it 'uses the application_v2 layout' do
      expect(response).to render_template(layout: 'application_v2')
    end

    it 'decorated object is the created public_page for tutorial' do
      expect(assigns(:public_page).object).to eq(public_page)
    end
  end

  describe '#preview' do
    let!(:page) { create(:page, page_type: 'preview-key', admin_access: false) }
    let!(:public_page) { create(:public_page, page: page) }

    before { get :preview, params: { id: 'preview-key' } }

    it 'renders the show template' do
      expect(response).to render_template('page/show')
    end

    it 'uses the application_v2 layout' do
      expect(response).to render_template(layout: 'application_v2')
    end

    it 'decorated object is the created public_page for preview' do
      expect(assigns(:public_page).object).to eq(public_page)
    end
  end
end
