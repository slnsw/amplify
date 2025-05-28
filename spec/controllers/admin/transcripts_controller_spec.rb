require 'rails_helper'

RSpec.describe Admin::TranscriptsController, type: :routing do
  it "routes GET /admin/transcripts to admin/transcripts#index" do
    expect(get: "/admin/transcripts").to route_to(controller: "admin/transcripts", action: "index")
  end

  it "does not route GET /admin/transcripts/1 to admin/transcripts#show" do
    expect(get: "/admin/transcripts/1").not_to route_to(controller: "admin/transcripts", action: "show", id: "1")
  end
end
