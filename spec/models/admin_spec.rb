# frozen_string_literal: true

RSpec.describe Admin do
  describe '.table_name_prefix' do
    it 'returns admin_ prefix' do
      expect(described_class.table_name_prefix).to eq('admin_')
    end
  end
end
