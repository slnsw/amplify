require "rails_helper"

RSpec.describe Admin::StatsController, type: :controller do
  let(:institution) { create(:institution) }
  let(:admin) { create(:user, :admin, institution: institution) }

  before do
    allow(controller).to receive(:authenticate_staff!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
    allow(controller).to receive(:authorize).and_return(true)
    allow(controller).to receive(:policy_scope).with(Institution).and_return([institution])
  end

  describe "GET #index" do
    it "assigns @institutions, @stats, and @flags and renders index" do
      stats_service = instance_double(StatsService, all_stats: { foo: "bar" })
      allow(StatsService).to receive(:new).with(admin).and_return(stats_service)
      flags = double("flags")
      allow(Flag).to receive(:pending_flags).with(admin.institution_id).and_return(flags)
      allow(flags).to receive(:paginate).and_return([double("flag")])

      get :index

      expect(assigns(:institutions)).to eq([institution])
      expect(assigns(:stats)).to eq({ foo: "bar" })
      expect(assigns(:flags)).to be_present
      expect(response).to render_template(:index)
    end
  end

  describe "GET #institution" do
    it "assigns @stats for the institution" do
      stats_service = instance_double(StatsService, transcript_edits: { edits: 5 })
      allow(StatsService).to receive(:new).with(admin).and_return(stats_service)
      allow(stats_service).to receive(:transcript_edits).with(institution.id.to_s).and_return({ edits: 5 })

      get :institution, params: { id: institution.id }

      expect(assigns(:stats)).to eq({ edits: 5 })
      expect(response).to render_template(:institution)
    end
  end
end
