require "rails_helper"

RSpec.describe RecalculateTranscriptsJob, type: :job do
  it "calls recalculate on the latest 250 transcripts" do
    transcripts = create_list(:transcript, 3)
    scope = double("scope")
    expect(Transcript).to receive(:order).with(updated_at: :desc).and_return(scope)
    expect(scope).to receive(:limit).with(250).and_return(transcripts)
    transcripts.each { |t| expect(t).to receive(:recalculate) }

    described_class.new.perform
  end
end
