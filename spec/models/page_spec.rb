# frozen_string_literal: true

RSpec.describe Page, type: :model do
  it { is_expected.to have_one(:public_page).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:page_type) }
  it { is_expected.to validate_uniqueness_of(:page_type) }
  it { is_expected.to validate_length_of(:page_type).is_at_most(50) }
  it { is_expected.to allow_value('abc_def').for(:page_type) }
  it { is_expected.to allow_value('abc_d_e-f').for(:page_type) }
  it { is_expected.not_to allow_value('abc def').for(:page_type) }
  it { is_expected.not_to allow_value('').for(:page_type) }
  it { is_expected.not_to allow_value('ab&ef').for(:page_type) }

  describe 'callbacks' do
    describe 'after_save' do
      context 'when published is true' do
        let(:page) { FactoryBot.build(:page, published: true) }

        it 'creates a PublicPage record' do
          expect { page.save }.to change(PublicPage, :count).by(1)
        end
      end

      context 'when published is false' do
        let(:page) { FactoryBot.build(:page, published: false) }

        it 'does not create a PublicPage record' do
          expect { page.save }.not_to change(PublicPage, :count)
        end
      end

      context 'when ignore_callbacks is true' do
        let(:page) { FactoryBot.build(:page, published: true) }

        it 'does not create a PublicPage record' do
          page.ignore_callbacks = true
          expect { page.save }.not_to change(PublicPage, :count)
        end
      end
    end
  end
end
