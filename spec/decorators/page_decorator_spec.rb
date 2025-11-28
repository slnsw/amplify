# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageDecorator do
  let(:page) { create(:page, content: '<p>Test content with <strong>HTML</strong></p>') }
  let(:decorator) { page.decorate }

  describe '#display_content' do
    it 'returns raw HTML content' do
      result = decorator.display_content
      expect(result).to include('<p>Test content with <strong>HTML</strong></p>')
    end

    it 'returns html_safe content' do
      result = decorator.display_content
      expect(result).to be_html_safe
    end

    it 'delegates all methods to page' do
      expect(decorator.title).to eq(page.title) if page.respond_to?(:title)
      expect(decorator.id).to eq(page.id)
    end
  end
end
