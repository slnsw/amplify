# frozen_string_literal: true

RSpec.describe Page, type: :model do
  # associations
  it { is_expected.to have_one(:public_page) }

  # validations
  it { is_expected.to validate_presence_of(:page_type) }
  it { is_expected.to validate_uniqueness_of(:page_type) }

  # page type
  it { is_expected.to validate_length_of(:page_type).is_at_most(50) }

  it { is_expected.to allow_value('abc_def').for(:page_type) }
  it { is_expected.to allow_value('abc_d_e-f').for(:page_type) }

  it { is_expected.not_to allow_value('abc def').for(:page_type) }
  it { is_expected.not_to allow_value('').for(:page_type) }
  it { is_expected.not_to allow_value('ab&ef').for(:page_type) }

  context 'when publishing a page' do
    let(:page) { FactoryBot.build(:page, published: published) }

    context 'when published is clicked' do
      let!(:published) { true }

      it 'adds the record to public_pages' do
        expect do
          page.save
        end.to change { PublicPage.count }.by(1)
      end
    end

    context 'when the page is on draft' do
      let!(:published) { false }

      it "doesn't update the public_pages" do
        expect do
          page.save
        end.to change { PublicPage.count }.by(0)
      end
    end
  end

  context 'with callbacks' do
    let(:page) { FactoryBot.build(:page, published: true) }

    context 'when skiping callbacks' do
      it "doesn't create a PublicPage" do
        expect do
          page.ignore_callbacks = true
          page.save
        end.to change { PublicPage.count }.by(0)
      end
    end

    context 'when not skiping callbacks' do
      it 'creates a PublicPage' do
        expect do
          page.save
        end.to change { PublicPage.count }.by(1)
      end
    end
  end

  context 'with destroy' do
    let(:public_page) { create :public_page }
    let!(:page) { public_page.page }

    it 'also deletes the public page' do
      expect do
        page.destroy
      end.to change { PublicPage.count }.by(-1)
    end
  end
end
