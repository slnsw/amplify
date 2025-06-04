require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
  let(:admin) { instance_double(User, admin?: true, id: 1) }
  let(:users_report) { double('users_report') }

  before do
    allow(controller).to receive(:authenticate_admin!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
  end

  before do
    controller.instance_variable_set(:@per_page, 20)
  end

  describe "GET #users" do
    context "as HTML" do
      it "assigns @users and renders html" do
        allow(User).to receive(:getReport).and_return(users_report)
        get :users, format: :html
        expect(assigns(:users)).to eq(users_report)
        expect(response).to render_template(:users)
        expect(response.content_type).to eq "text/html; charset=utf-8"
      end

      it "assigns date strings" do
        allow(User).to receive(:getReport).and_return(users_report)
        get :users, format: :html
        expect(assigns(:start_date_str)).to be_a(String)
        expect(assigns(:end_date_str)).to be_a(String)
      end

      it "passes params to User.getReport" do
        expect(User).to receive(:getReport).with(
          hash_including(
            page: 1,
            start_date: kind_of(ActiveSupport::TimeWithZone),
            end_date: kind_of(ActiveSupport::TimeWithZone)
          )
        ).and_return(users_report)
        get :users, format: :html
      end

      it "uses params for pagination and dates" do
        allow(User).to receive(:getReport).and_return(users_report)
        get :users, params: {
          page: 2,
          per_page: 50,
          start_date: "2022-01-01",
          end_date: "2022-01-31"
        }, format: :html
        expect(assigns(:users)).to eq(users_report)
        expect(assigns(:start_date_str)).to eq("2022-01-01")
        expect(assigns(:end_date_str)).to eq("2022-01-31")
      end
    end

    context "as CSV" do
      before do
        allow(controller).to receive(:render_csv).and_call_original
      end

      it "renders CSV with correct headers" do
        get :users, format: :csv
        expect(response.headers["Content-Disposition"]).to match(/attachment; filename="users-\d{8}-\d{6}\.csv"/)
        expect(response.headers["Content-Type"]).to include("text/csv")
      end

      it "calls render_csv" do
        expect(controller).to receive(:render_csv).with(/users-\d{8}-\d{6}/).and_call_original
        get :users, format: :csv
      end
    end
  end

  describe "authentication" do
    it "redirects if not authenticated" do
      allow(controller).to receive(:authenticate_admin!).and_call_original
      allow(controller).to receive(:current_user).and_return(nil)
      get :users, format: :html
      expect(response).to have_http_status(:redirect).or have_http_status(:found)
    end
  end

  before do
    allow(admin).to receive(:total_edits).and_return(nil)
    allow(admin).to receive(:total_edits=)
  end
end
