# frozen_string_literal: true

RSpec.shared_examples 'uid_not_updatable' do
  describe 'uid validation on update concern' do
    # Define factory_options as an empty hash if not provided
    let(:factory_options) { {} }

    context 'when the record is new' do
      it 'allows setting the uid' do
        new_record = create(factory_name, factory_options.merge(uid: 'new-uid'))
        expect(new_record).to be_persisted
        expect(new_record.uid).to eq('new-uid')
      end
    end

    context 'when the record is persisted' do
      it 'does not allow changing the uid' do
        record = create(factory_name, factory_options)
        record.uid = 'changed-uid'
        expect(record).not_to be_valid
        expect(record.errors[:uid]).to include('cannot be updated')
      end

      it 'allows saving without changing uid' do
        record = create(factory_name, factory_options)
        record.save
        expect(record).to be_valid
      end
    end
  end
end
