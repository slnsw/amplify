require 'rails_helper'

RSpec.describe RecalculateTranscriptsJob do
  describe "#perform_later" do
    it "enqueues job" do
      ActiveJob::Base.queue_adapter = :test

      expect { described_class.perform_later }.to have_enqueued_job
    end
  end
end
