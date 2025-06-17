# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#display_time' do
    it 'returns correct time' do
      expect(helper.display_time(152_940)).to eq('42h 29m')
    end
  end
end
