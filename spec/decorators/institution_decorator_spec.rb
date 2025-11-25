# frozen_string_literal: true

RSpec.describe InstitutionDecorator, type: :decorator do
  let(:institution) { create(:institution, slug: 'test-slug', url: 'https://example.com') }
  let(:decorator) { institution.decorate }

  describe '#path' do
    it 'returns the institution path' do
      expect(decorator.path).to eq('/test-slug')
    end
  end

  describe '#absolute_url' do
    it 'returns the institution url' do
      expect(decorator.absolute_url).to eq('https://example.com')
    end
  end
end
