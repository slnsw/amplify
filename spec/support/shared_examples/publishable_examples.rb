# frozen_string_literal: true

RSpec.shared_examples 'publishable' do
  describe 'publishable concern' do
    # Define factory_options as an empty hash if not provided
    let(:factory_options) { {} }

    describe 'scopes' do
      describe '.published' do
        let!(:published_record) { create(factory_name, factory_options.merge(publish: 1)) }
        let!(:unpublished_record) { create(factory_name, factory_options.merge(publish: 0)) }

        it 'includes records with published_at set' do
          expect(described_class.published).to include(published_record)
        end

        it 'excludes records with published_at nil' do
          expect(described_class.published).not_to include(unpublished_record)
        end
      end

      describe '.unpublished' do
        let!(:published_record) { create(factory_name, factory_options.merge(publish: 1)) }
        let!(:unpublished_record) { create(factory_name, factory_options.merge(publish: 0)) }

        it 'includes records with published_at nil' do
          expect(described_class.unpublished).to include(unpublished_record)
        end

        it 'excludes records with published_at set' do
          expect(described_class.unpublished).not_to include(published_record)
        end
      end
    end

    describe 'instance methods' do
      describe '#published?' do
        context 'when published_at is present' do
          it 'returns true' do
            record = create(factory_name, factory_options.merge(publish: 1))
            expect(record).to be_published
          end
        end

        context 'when published_at is nil' do
          it 'returns false' do
            record = create(factory_name, factory_options.merge(publish: 0))
            expect(record).not_to be_published
          end
        end
      end

      describe '#unpublished?' do
        context 'when published_at is nil' do
          it 'returns true' do
            record = create(factory_name, factory_options.merge(publish: 0))
            expect(record).to be_unpublished
          end
        end

        context 'when published_at is present' do
          it 'returns false' do
            record = create(factory_name, factory_options.merge(publish: 1))
            expect(record).not_to be_unpublished
          end
        end
      end

      describe '#publish!' do
        it 'sets published_at to current time' do
          record = create(factory_name, factory_options.merge(publish: 0))
          expect { record.publish! }
            .to change { record.reload.published_at }.from(nil).to(be_within(1.second).of(Time.current))
        end
      end

      describe '#unpublish!' do
        it 'sets published_at to nil' do
          record = create(factory_name, factory_options.merge(publish: 1))
          expect { record.unpublish! }
            .to change { record.reload.published_at }.to(nil)
        end
      end
    end

    describe 'callbacks' do
      describe 'after_save :publish_if_needed' do
        context 'when publish attribute changes from false to true' do
          it 'publishes the record' do
            record = create(factory_name, factory_options.merge(publish: 0))
            expect { record.update(publish: 1) }
              .to change { record.reload.published? }.from(false).to(true)
          end
        end

        context 'when publish attribute changes from true to false' do
          it 'unpublishes the record' do
            record = create(factory_name, factory_options.merge(publish: 1))
            expect { record.update(publish: 0) }
              .to change { record.reload.published? }.from(true).to(false)
          end
        end
      end
    end
  end
end
