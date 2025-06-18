require "rails_helper"

RSpec.describe Admin::SiteAlertsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let!(:site_alert) do
    SiteAlert.create!(
      machine_name: "alert_#{SecureRandom.hex(8)}",
      message: "MyText",
      user_id: admin.id,
      publish_at: Time.zone.now,
      unpublish_at: Time.zone.now + 1.day,
    )
  end

  before do
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:authorize).and_return(true)
    allow(controller).to receive(:policy_scope).and_return(SiteAlert.all)
  end

  describe "GET #index" do
    it "assigns @site_alerts and renders index" do
      get :index
      expect(assigns(:site_alerts)).to include(site_alert)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    it "assigns a new site_alert and renders new" do
      get :new
      expect(assigns(:site_alert)).to be_a_new(SiteAlert)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    it "creates a site_alert and redirects on success" do
      expect do
        post :create, params: { site_alert: {
          machine_name: "alert_#{SecureRandom.hex(8)}",
          message: "MyText",
          user_id: admin.id,
          publish_at: Time.zone.now,
          unpublish_at: Time.zone.now + 1.day,
        } }
      end.to change(SiteAlert, :count).by(1)
      expect(response).to redirect_to(admin_site_alerts_path)
    end

    it "renders new on failure" do
      expect do
        post :create, params: { site_alert: { machine_name: "alert_#{SecureRandom.hex(8)}", message: "" } }
      end.not_to change(SiteAlert, :count)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns the site_alert and renders edit" do
      get :edit, params: { id: site_alert.id }
      expect(assigns(:site_alert)).to eq(site_alert)
      expect(response).to render_template(:edit)
    end
  end

  describe "GET #show" do
    it "assigns and decorates the site_alert" do
      get :show, params: { id: site_alert.id }
      expect(assigns(:site_alert)).to be_present
      expect(response).to render_template(:show)
    end
  end

  describe "PATCH #update" do
    it "updates and redirects on success" do
      patch :update, params: { id: site_alert.id, site_alert: { message: "Updated" } }
      expect(response).to redirect_to(admin_site_alerts_path)
      expect(site_alert.reload.message).to eq("Updated")
    end

    it "renders edit on failure" do
      patch :update, params: { id: site_alert.id, site_alert: { message: "" } }
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the site_alert and redirects" do
      expect do
        delete :destroy, params: { id: site_alert.id }
      end.to change(SiteAlert, :count).by(-1)
      expect(response).to redirect_to(admin_site_alerts_path)
    end
  end
end
