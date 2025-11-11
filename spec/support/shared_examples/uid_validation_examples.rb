# frozen_string_literal: true

RSpec.shared_examples 'uid_validatable' do
  describe 'uid validation concern' do
    # Define factory_options as an empty hash if not provided
    let(:factory_options) { {} }

    describe 'format validation' do
      context 'with valid uid formats' do
        it { is_expected.to allow_value('abc_def').for(:uid) }
        it { is_expected.to allow_value('abc-def').for(:uid) }
        it { is_expected.to allow_value('ABC123').for(:uid) }
        it { is_expected.to allow_value('test_uid-123').for(:uid) }
      end

      context 'with invalid uid formats' do
        it { is_expected.not_to allow_value('abc def').for(:uid) }
        it { is_expected.not_to allow_value('abc@def').for(:uid) }
        it { is_expected.not_to allow_value('abc!def').for(:uid) }
        it { is_expected.not_to allow_value('abc.def').for(:uid) }
        it { is_expected.not_to allow_value('').for(:uid) }
      end
    end

    describe 'length validation' do
      it { is_expected.to validate_length_of(:uid).is_at_least(1).is_at_most(50) }

      context 'when uid is exactly 50 characters' do
        it 'is valid' do
          record = create(factory_name, factory_options.merge(uid: 'a' * 50))
          expect(record).to be_persisted
          expect(record.uid.length).to eq(50)
        end
      end

      context 'when uid exceeds 50 characters' do
        it 'is invalid' do
          record = build(factory_name, factory_options.merge(uid: 'a' * 51))
          expect(record).not_to be_valid
        end

        it 'has error on uid attribute' do
          record = build(factory_name, factory_options.merge(uid: 'a' * 51))
          record.valid?
          expect(record.errors[:uid]).to be_present
        end
      end
    end
  end
end
