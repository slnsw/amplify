require 'rails_helper'

RSpec.describe DeleteInstitutionJob do
  let!(:institution) { create(:institution) }
  let(:user) { create(:user) }

  describe "#perform_later" do
    it "enqueues job" do
      ActiveJob::Base.queue_adapter = :test

      expect {
        described_class.perform_later(institution.name, institution.id, user.email)
      }.to have_enqueued_job
    end

    it 'destroy institution and execute mailer' do
      mailer = double(deliver_now: true)
      allow(InstitutionMailer).to receive(:delete_institution).and_return(mailer)

      expect(InstitutionMailer).to receive(:delete_institution).and_return(mailer)
      expect {
        described_class.perform_now(institution.name, institution.id, user.email)
      }.to change { Institution.count }.by(-1)
    end
  end
end
