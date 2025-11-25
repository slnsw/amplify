# frozen_string_literal: true

RSpec.describe InstitutionMailer, type: :mailer do
  describe '#delete_institution' do
    let(:institution_name) { 'Test Institution' }
    let(:user_email) { 'user@example.com' }
    let(:mail) { described_class.delete_institution(institution_name, user_email) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Amplify: Test Institution was succesfully deleted.')
    end

    it 'sends to the correct email' do
      expect(mail.to).to eq([user_email])
    end

    it 'sets the institution name in the email body' do
      expect(mail.body.encoded).to include(institution_name)
    end
  end
end
