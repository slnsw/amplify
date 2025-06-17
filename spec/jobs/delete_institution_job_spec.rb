# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteInstitutionJob, type: :job do
  let(:institution) { create(:institution, name: 'Test Institution') }
  let(:user_email) { 'user@example.com' }

  it 'destroys the institution and sends a mail' do
    expect(Institution).to receive(:find_by).with(id: institution.id).and_return(institution)
    expect(institution).to receive(:destroy)
    mailer = double('InstitutionMailer')
    expect(InstitutionMailer).to receive(:delete_institution)
      .with('Test Institution', user_email)
      .and_return(mailer)
    expect(mailer).to receive(:deliver_now)

    described_class.new.perform('Test Institution', institution.id, user_email)
  end

  it 'still sends a mail if institution is not found' do
    expect(Institution).to receive(:find_by).with(id: 999).and_return(nil)
    mailer = double('InstitutionMailer')
    expect(InstitutionMailer).to receive(:delete_institution)
      .with('Ghost Institution', user_email)
      .and_return(mailer)
    expect(mailer).to receive(:deliver_now)

    described_class.new.perform('Ghost Institution', 999, user_email)
  end
end
