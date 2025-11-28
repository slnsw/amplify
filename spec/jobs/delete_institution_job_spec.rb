# frozen_string_literal: true

RSpec.describe DeleteInstitutionJob, type: :job do
  describe '#perform' do
    let(:institution) { create(:institution, name: 'Test Institution') }
    let(:user_email) { 'admin@example.com' }
    let(:mailer) { double('mailer', deliver_now: true) }

    before do
      allow(InstitutionMailer).to receive(:delete_institution).and_return(mailer)
    end

    context 'when institution exists' do
      it 'destroys the institution' do
        institution_id = institution.id
        expect(Institution.exists?(institution_id)).to be true
        described_class.perform_now(institution.name, institution_id, user_email)
        expect(Institution.exists?(institution_id)).to be false
      end

      it 'sends deletion email' do
        described_class.perform_now(institution.name, institution.id, user_email)
        expect(InstitutionMailer).to have_received(:delete_institution).with(institution.name, user_email)
        expect(mailer).to have_received(:deliver_now)
      end
    end

    context 'when institution does not exist' do
      it 'still sends email' do
        described_class.perform_now('Nonexistent', 99_999, user_email)
        expect(InstitutionMailer).to have_received(:delete_institution).with('Nonexistent', user_email)
      end

      it 'does not raise error' do
        expect do
          described_class.perform_now('Nonexistent', 99_999, user_email)
        end.not_to raise_error
      end
    end
  end
end
